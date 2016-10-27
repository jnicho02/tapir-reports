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
        tmpfiles = []
        content = ""
        Zip::File.open(@template) do |zipfile|
          # OpenOffice
#          %w(content.xml styles.xml).each do |entry|
          filenames.each do |entry|
            content = zipfile.read(entry)

            # Image replacement
#              images_replacements = ImagesProcessor.new(content, context).generate_replacements
#              images_replacements.each do |r|
#                zipfile.replace(r.first, r.last)
#              end

#TODO: levelling

            data = JSON.parse(json_string, object_class: OpenStruct)
#            object = OpenStruct.new(name: 'Joan', last: 'Maragall'
            puts data.person
            puts ERB.new("Hello <%= person %>").result(data.instance_eval { binding })

            puts "content b4 = #{content}"

            content.gsub!('&lt;%=','<%=')
            content.gsub!('%&gt;','%>')

#TODO: use something like https://github.com/VisualOn/OpenXmlPowerTools/blob/master/MarkupSimplifier.cs to simplify Word xml
            puts "content pre = #{content}"
            content = ERB.new(content).result(data.instance_eval { binding })
            puts "content after = #{content}"

#              tmpfiles << (file = Tempfile.new("serenity"))
#              file << out
#              file.close

#              zipfile.replace(xml_file, file.path)
          end
        end

        content
      end

      # from https://github.com/rubyzip/rubyzip docs
      def output
        buffer = Zip::OutputStream.write_buffer do |out|
          @zip_file.entries.each do |e|
            unless [DOCUMENT_FILE_PATH, RELS_FILE_PATH].include?(e.name)
              out.put_next_entry(e.name)
              out.write e.get_input_stream.read
             end
          end

          out.put_next_entry(DOCUMENT_FILE_PATH)
          out.write xml_doc.to_xml(:indent => 0).gsub("\n","")

          out.put_next_entry(RELS_FILE_PATH)
          out.write rels.to_xml(:indent => 0).gsub("\n","")
        end

        File.open(new_path, "wb") {|f| f.write(buffer.string) }
      end
    end
  end
end
