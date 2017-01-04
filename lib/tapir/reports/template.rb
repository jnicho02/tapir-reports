require 'zip'
require 'erb'
require 'json'
require 'ostruct'
require 'nokogiri'

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

      def image_names
        names = []
        xml = Nokogiri::XML(@content)
        xml.root.add_namespace('xmlns:a', 'xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main')
        xml.xpath("//w:drawing").each do |node|
          blip = node.xpath("*/wp:docPr")
          title = blip.attribute('title').value
          names << title
        end
        names
      end

      def relationship_id(image_name)
        xml = Nokogiri::XML(@content)
        xml.root.add_namespace('xmlns:a','http://schemas.openxmlformats.org/drawingml/2006/main')
        xml.at_xpath("//w:drawing[*/wp:docPr[@title='#{image_name}']]//a:blip/@r:embed").value
      end

      def url(relationship_id)
        xml = Nokogiri::XML(@relationships)
        'word/' + xml.at_xpath("//*[@Id='#{relationship_id}']/@Target")
      end

      def url_for(image_name)
        url(relationship_id(image_name))
      end

      def output(json_string, image_replacements)
        urls = []
        image_replacements2 = {}
        image_replacements.each { |rep|
          urls << url_for(rep[0])
          image_replacements2[url_for(rep[0])] = rep[1]
        }
        json = JSON.parse(json_string, object_class: OpenStruct)
        @zipfile = Zip::File.open(@template)
        buffer = Zip::OutputStream.write_buffer { |out|
          @zipfile.entries.each { |entry|
            if 'word/document.xml' == entry.name
              out.put_next_entry(entry)
              processed_content = render(json, @content)
              out.write(processed_content)
            elsif urls.include?(entry.name)
              out.put_next_entry(entry)
              File.open(image_replacements2[entry.name], 'rb') {|input| out.write(input.read)}
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
