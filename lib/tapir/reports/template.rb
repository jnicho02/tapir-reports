require 'zip'
require 'erb'
require 'json'
require 'ostruct'
require 'nokogiri'

module Tapir
  module Reports
    class Template
      attr_accessor :template

      def initialize(template)
        @template = template
      end

      def extension
        @template.split('.').last
      end

      def filenames
        case extension
        when 'odt'
#          %w(content.xml styles.xml)
          %w(content.xml)
        when 'docx'
          %w(word/document.xml)
        else
          []
        end
      end

      def word?
        extension == "docx"
      end

      def process(json, content)
        content.gsub!('&lt;%=','<%=')
        content.gsub!('%&gt;','%>')
#TODO: use something like https://github.com/VisualOn/OpenXmlPowerTools/blob/master/MarkupSimplifier.cs to simplify Word xml
        content = ERB.new(content).result(json.instance_eval { binding })
        content
      end

      def image_names
        names = []
        @zipfile = Zip::File.open(@template)
        content = word? ? @zipfile.read('word/document.xml') : @zipfile.read('content.xml')
        xml = Nokogiri::XML(content)
        if word?
          xml.root.add_namespace('xmlns:a','xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main')
          xml.xpath("//w:drawing").each do |node|
            blip = node.xpath("*/wp:docPr")
            title = blip.attribute('title').value
            names << title
          end
        else
          xml.xpath("//draw:frame[draw:image]").each do |node|
            title = node.xpath("svg:title").text
  #          placeholder_path = node.attribute('href').value
            names << title
          end
        end
        names
      end

      def output(json_string, kitten_image)
        json = JSON.parse(json_string, object_class: OpenStruct)
        @zipfile = Zip::File.open(@template)
        buffer = Zip::OutputStream.write_buffer do |out|
          @zipfile.entries.each do |entry|
            if filenames.include?(entry.name)
              content = @zipfile.read(entry)
              out.put_next_entry(entry)
              out.write(process(json,content))
            elsif entry.name.include?('word/media/image1.jpg')
              out.put_next_entry(entry)
              File.open(kitten_image, 'rb') {|input| out.write(input.read)}
            else
              out.put_next_entry(entry.name)
              out.write entry.get_input_stream.read
            end
          end
        end

        File.open("/Users/jeznicholson/Projects/tapir-reports/fixtures/mangled.#{extension}", "wb") {|f| f.write(buffer.string) }
      end
    end
  end
end
