require 'erb'
require 'json'
require 'nokogiri'
require 'open-uri'
require 'ostruct'
require 'zip'

module Tapir
  module Reports
    class Template
      attr_accessor :template
      attr_accessor :content

      def initialize(template)
        @template = template
        @zipfile = Zip::File.open(@template)
        @content = @zipfile.read('word/document.xml')
        @relationships = @zipfile.read('word/_rels/document.xml.rels')
        @zipfile.close
      end

      def render(json, content)
        erb = Template.sanitize(content)
        ERB.new(erb).result(json.instance_eval { binding })
      end

      def self.sanitize(content)
        # remove all extraneous Word xml tags between erb start and finish
        content.gsub!(/(&lt;%[^%]*%&gt;)/m) { |erb_tag|
          erb_tag.gsub(/(<[^>]*>)/, '')
        }
        content.gsub!('&lt;%', '<%')
        content.gsub!('%&gt;', '%>')
        content
      end

      def relationship_id(image_name)
        xml = Nokogiri::XML(@content)
        xml.root.add_namespace('xmlns:a','http://schemas.openxmlformats.org/drawingml/2006/main')
        node = xml.at_xpath("//w:drawing[*/wp:docPr[@title='#{image_name}']]//a:blip/@r:embed")
        nil
        node.value if node
      end

      def url(relationship_id)
        xml = Nokogiri::XML(@relationships)
        'word/' + xml.at_xpath("//*[@Id='#{relationship_id}']/@Target")
      end

      def url_for(image_name)
        nil
        url(relationship_id(image_name)) if relationship_id(image_name)
      end

      def output(json_string, image_replacements)
        image_replacements2 = {}
        image_replacements.each { |rep|
          url = url_for(rep[0])
          image_replacements2[url] = rep[1] if url != nil
        }
        begin
          json = JSON.parse(json_string, object_class: OpenStruct)
        rescue
          json = json_string
        end
        @zipfile = Zip::File.open(@template)
        buffer = Zip::OutputStream.write_buffer { |out|
          @zipfile.entries.each { |entry|
            if 'word/document.xml' == entry.name
              out.put_next_entry(entry)
              processed_content = render(json, @content)
              out.write(processed_content)
            elsif image_replacements2.keys.include?(entry.name)
              out.put_next_entry(entry)
              open(image_replacements2[entry.name]) {|f| out.write(f.read)}
            else
              out.put_next_entry(entry.name)
              out.write(entry.get_input_stream.read)
            end
          }
        }
        return buffer.string
      end

      def write_to_file(json_string, image_replacements, output_name)
        s = output(json_string, image_replacements)
        File.open("/Users/jeznicholson/Projects/tapir-reports/fixtures/#{output_name}", "wb") {|f| f.write(s) }
      end
    end
  end
end
