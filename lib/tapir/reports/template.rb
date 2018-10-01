require 'erb'
require 'json'
require 'nokogiri'
require 'open-uri'
require 'ostruct'
require 'zip'

module Tapir
  module Reports
    class Template

      def initialize(template)
        @template = template
        # open the template, cache the bits we are interested in, then close
        template_opened = open(@template)
        zipfile = Zip::File.open_buffer(template_opened)
        @relationships = zipfile.read('word/_rels/document.xml.rels')
        @files = {
          'word/document.xml' => zipfile.read('word/document.xml'),
          'docProps/core.xml' => zipfile.read('docProps/core.xml'),
        }
        zipfile.glob(File.join("**", "header*.xml")).each { |e|
          @files[e.name] = zipfile.read(e)
        }
        zipfile.glob(File.join("**", "footer*.xml")).each { |e|
          @files[e.name] = zipfile.read(e)
        }
        zipfile.close
      end

      def render(your_binding, key='word/document.xml')
        erb = Template.to_erb(@files[key])
        ERB.new(erb).result(your_binding)
      end

      def self.to_erb(content)
        # remove extraneous Word xml tags between erb start and finish
        # enable anti-nil syntax 'xyz&.attr'
        content.gsub!(/(&lt;%[^%]*%&gt;)/m) { |erb_tag|
          erb_tag.gsub(/(<[^>]*>)/, '').gsub('&amp;', '&')
        }
        # unescape erb tags
        content.gsub!('&lt;%', '<%')
        content.gsub!('%&gt;', '%>')
        content
      end

      def relationship_id(image_name)
        xml = Nokogiri::XML(@files['word/document.xml'])
        xml.root.add_namespace('xmlns:a','http://schemas.openxmlformats.org/drawingml/2006/main')
        drawing = xml.at_xpath("//w:drawing[*/wp:docPr[@title='#{image_name}']]")
        node = drawing.at_xpath("*//a:blip/@r:embed") if drawing
        # if nil then object is not a picture, it is a border box or something
        nil
        node.value if node
      end

      def url(relationship_id)
        relationships = Nokogiri::XML(@relationships)
        target =  relationships.at_xpath("//*[@Id='#{relationship_id}']/@Target")
        "word/#{target}"
      end

      def url_for(image_name)
        nil
        url(relationship_id(image_name)) # if relationship_id(image_name)
      end

      def output(your_binding, image_replacements)
        image_replacements2 = {}
        image_replacements.each { |rep|
          url = url_for(rep[0])
          image_replacements2[url] = rep[1] if url != nil
        }
        buffer = Zip::OutputStream.write_buffer { |out|
          zipfile = Zip::File.open_buffer(open(@template))
          zipfile.entries.each { |entry|
            if @files.keys.include?(entry.name)
              rendered_document_xml = render(your_binding, entry.name)
              out.put_next_entry(entry.name)
              out.write(rendered_document_xml)
            elsif image_replacements2.keys.include?(entry.name)
              # write the alternative image's contents instead of placeholder's
              out.put_next_entry(entry.name)
              begin
                open(image_replacements2[entry.name]) {|f| out.write(f.read)}
              rescue
                open("https://github.com/jnicho02/tapir-reports/raw/master/lib/tapir/reports/image-not-found.png") {|f| out.write(f.read)}
              end
            else
              out.put_next_entry(entry.name)
              out.write(entry.get_input_stream.read)
            end
          }
          zipfile.close
        }
        buffer.string
      end

    end
  end
end
