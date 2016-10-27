require 'zip'
require 'erb'
require 'json'
require 'ostruct'

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

      def process json_string
        data = JSON.parse(json_string, object_class: OpenStruct)
        content = ""
        Zip::File.open(@template) do |zipfile|
          filenames.each do |entry|
            content = zipfile.read(entry)
            content.gsub!('&lt;%=','<%=')
            content.gsub!('%&gt;','%>')
#TODO: use something like https://github.com/VisualOn/OpenXmlPowerTools/blob/master/MarkupSimplifier.cs to simplify Word xml
#            puts "content pre = #{content}"
            content = ERB.new(content).result(data.instance_eval { binding })
#            puts "content after = #{content}"
          end
        end

        content
      end

      def output json_string
        data = JSON.parse(json_string, object_class: OpenStruct)
        @zipfile = Zip::File.open(@template)
        buffer = Zip::OutputStream.write_buffer do |out|
          @zipfile.entries.each do |e|
            unless filenames.include?(e.name)
              out.put_next_entry(e.name)
              out.write e.get_input_stream.read
             end
          end

          filenames.each do |entry|
            content = @zipfile.read(entry)
            content.gsub!('&lt;%=','<%=')
            content.gsub!('%&gt;','%>')
            content = ERB.new(content).result(data.instance_eval { binding })
            out.put_next_entry(entry)
            out.write content
          end
        end

        File.open("/Users/jeznicholson/Projects/tapir-reports/fixtures/mangled.#{extension}", "wb") {|f| f.write(buffer.string) }
      end
    end
  end
end
