require 'erb'
require 'json'
require 'nokogiri'
require 'open-uri'
require 'ostruct'
require 'zip'

module Tapir
  module Reports
    # a template in Word docx format
    class Template
      def initialize(template)
        @template = template
        # open the template, cache the bits we are interested in, then close
        template_opened = URI.open(@template)
        zipfile = Zip::File.open_buffer(template_opened)
        @relationships = zipfile.read('word/_rels/document.xml.rels')
        @files = {
          'word/document.xml' => zipfile.read('word/document.xml')
        }
        @files['docProps/core.xml'] = zipfile.read('docProps/core.xml') unless zipfile.find_entry('docProps/core.xml').nil?
        zipfile.glob(File.join('**', 'header*.xml')).each { |e| @files[e.name] = zipfile.read(e) }
        zipfile.glob(File.join('**', 'footer*.xml')).each { |e| @files[e.name] = zipfile.read(e) }
        zipfile.close
      end

      def contents
        @files['word/document.xml']
      end

      def render(your_binding, key = 'word/document.xml')
        erb = Template.to_erb(@files[key])
        ERB.new(erb, trim_mode: '-').result(your_binding)
      end

      def self.to_erb(content)
        # remove extraneous Word xml tags between erb start and finish
        # enable anti-nil syntax 'xyz&.attr'
        content.gsub!(/(&lt;%[^%]*%[^&]*&gt;)/m) do |erb_tag|
          erb_tag.gsub(/(<[^>]*>)/, '').gsub('&amp;', '&').gsub('‘', "'")
        end
        # unescape erb tags
        content.gsub!('&lt;%', '<%')
        content.gsub!('%&gt;', '%>')
        content
      end

      # This is still pretty dirty, but you get a Word transformation as html.erb
      def self.to_bootstrap_erb(content, replacements = [])
        content = to_erb(content)
        content.gsub!('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>', '<!DOCTYPE html>')
        content.gsub!('w:document', 'html')
        content.gsub!('w:body', 'body')
        content.gsub!(/<html(\s[^>]*>|>)/, '<html lang="en-GB">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <!-- Bootstrap CSS -->
          <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
        </head>')
        content.gsub!('<body>', '<body><script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>')
        content = strip_tag(content, 'mc:AlternateContent')
        content = strip_tag(content, 'wps:bodyPr')
        content = strip_tag(content, 'w:rPr')
        content = strip_tag(content, 'w:sectPr')
        content = strip_tag(content, 'w:tblPr')
        content = strip_tag(content, 'w:trPr')
        content = strip_tag(content, 'w:tcPr')
        content = strip_tag(content, 'w:tblGrid')
        content = replace_tag(content, 'w:drawing', replacements)
        content = strip_tag(content, 'w:drawing')
        content = strip_tag(content, 'w:pict')
        close_div = '</div>'.freeze
        content.gsub!(/<w:p(\s[^>]*>|>)/, '<w:p>')
        content.gsub!(/<w:r(\s[^>]*>|>)/, '<w:r>')
        content.gsub!(/<w:right(\s[^>]*>|>)/, '<w:right>')
        content.gsub!(/<w:tr(\s[^>]*>|>)/, '<w:tr>')
        content.gsub!(%r{<w:tcW(\s[^>]*/>)}, '')
        content.gsub!(%r{<w:proofErr(\s[^>]*/>)}, '')
        content.gsub!('<w:tbl>', '<div class="container">')
        content.gsub!('</w:tbl>', close_div)
        content.gsub!('<w:tbl>', '')
        content.gsub!('</w:tbl>', '')
        content.gsub!('<w:tr>', '<div class="row">')
        content.gsub!('</w:tr>', close_div)
        content.gsub!(%r{<w:p><w:pPr><w:pStyle w:val="Heading1"/>}, '<p class="h1"><w:pPr>')
        content.gsub!(%r{<w:p><w:pPr><w:pStyle w:val="Heading2"/>}, '<p class="h2"><w:pPr>')
        content.gsub!(%r{<w:p><w:pPr><w:pStyle w:val="Heading3"/>}, '<p class="h3"><w:pPr>')
        content.gsub!(%r{<w:p><w:pPr><w:pStyle w:val="Heading4"/>}, '<p class="h4"><w:pPr>')
        content.gsub!('<w:p>', '<p>')
        content.gsub!('</w:p>', '</p>')
        content = strip_tag(content, 'w:pPr')
        content.gsub!('<w:r>', '')
        content.gsub!('</w:r>', '')
        content.gsub!('<w:tc>', '<div class="col-auto">')
        content.gsub!('</w:tc>', close_div)
        content.gsub!(/<w:t(\s[^>]*>|>)/, '')
        content.gsub!('</w:t>', '')
        content.gsub!('<w:temporary/>', '')
        content.gsub!('<w:showingPlcHdr/>', '')
        content.gsub!('<w:text/>', '')
        content.gsub!('<w:sdtEndPr/>', '')
        content.gsub!('<w:br w:type="page"/>', '** page break **')
        content.gsub!('<w15:appearance w15:val="hidden"/>', '')
        content.gsub!(%r{<w:id [^>]*/>}, '')
        content = remove_tag(content, 'w:sdt')
        content = remove_tag(content, 'w:sdtContent')
        content = remove_tag(content, 'w:sdtPr')
        content = remove_tag(content, 'w:placeholder')
        content.gsub!(%r{<w:docPart [^>]*/>}, '')
        content
      end

      def relationship_id(image_name)
        xml = Nokogiri::XML(@files['word/document.xml'])
        xml.root.add_namespace('xmlns:a', 'http://schemas.openxmlformats.org/drawingml/2006/main')
        drawing = xml.at_xpath("//w:drawing[*/wp:docPr[@title='#{image_name}' or @descr='#{image_name}']]")
        node = drawing.at_xpath('*//a:blip/@r:embed') if drawing
        # if nil then object is not a picture, it is a border box or something
        node&.value
      end

      def self.replace_tag(content, tag, replacements)
        open_tag = "<#{tag}"
        close_tag = "</#{tag}>"
        while content.index(open_tag)
          up_to_start_tag = content[0..content.index(open_tag) - 1]
          between_tags = content[content.index(open_tag)..content.index(close_tag)]
          after_close_tag = content[content.index(close_tag) + close_tag.size..]
          found = false
          replacements.each do |r|
            look_for = "descr=\"#{r[0]}\""
            next unless between_tags.include?(look_for)

            found = true
            img_tag = "<img src='#{r[1]}' height=200 alt='#{r[0]}'/>"
            puts "found #{look_for}, inserting #{img_tag}"
            content = up_to_start_tag + img_tag + after_close_tag
          end
          content = up_to_start_tag + after_close_tag unless found
        end
        content
      end

      # remove <tag>but leave everything between be</tag>
      def self.remove_tag(content, tag)
        open_tag = "<#{tag}>"
        close_tag = "</#{tag}>"
        while content.index(open_tag)
          up_to_start_tag = content[0..content.index(open_tag) - 1]
          after_up_to_start = content[content.index(open_tag) + open_tag.size..]
          between = after_up_to_start[0..after_up_to_start.index(close_tag) - 1]
          after_close_tag = after_up_to_start[after_up_to_start.index(close_tag) + close_tag.size..]
          content = up_to_start_tag + between + after_close_tag
        end
        content
      end

      # remove <tag>and everything between</tag>
      def self.strip_tag(content, tag)
        open_tag = "<#{tag}"
        close_tag = "</#{tag}>"
        while content.index(open_tag)
          up_to_start_tag = content[0..content.index(open_tag) - 1]
          after_close_tag = content[content.index(close_tag) + close_tag.size..]
          content = up_to_start_tag + after_close_tag
        end
        content
      end

      def url(relationship_id)
        relationships = Nokogiri::XML(@relationships)
        target = relationships.at_xpath("//*[@Id='#{relationship_id}']/@Target")
        "word/#{target}"
      end

      def url_for(image_name)
        url(relationship_id(image_name)) # if relationship_id(image_name)
      end

      def output(your_binding, image_replacements)
        image_replacements2 = {}
        image_replacements.each do |rep|
          url = url_for(rep[0])
          image_replacements2[url] = rep[1] unless url.nil?
        end
        buffer = Zip::OutputStream.write_buffer do |out|
          zipfile = Zip::File.open_buffer(URI.open(@template))
          zipfile.entries.each do |entry|
            if @files.keys.include?(entry.name)
              puts("rendering #{entry.name}")
              rendered_document_xml = render(your_binding, entry.name)
              out.put_next_entry(entry.name)
              out.write(rendered_document_xml)
            elsif image_replacements2.keys.include?(entry.name)
              puts("replacing #{entry.name}")
              # write the alternative image's contents instead of placeholder's
              out.put_next_entry(entry.name)
              begin
                URI.open(image_replacements2[entry.name]) do |f|
                  data = f.read
                  signature = data[0, 3].bytes
                  if [[255, 216, 255], [137, 80, 78]].include?(signature)
                    out.write(data)
                  else
                    URI.open('https://github.com/jnicho02/tapir-reports/raw/master/lib/tapir/reports/image-not-found.png') { |not_found| out.write(not_found.read) }
                  end
                end
              rescue
                URI.open('https://github.com/jnicho02/tapir-reports/raw/master/lib/tapir/reports/image-not-found.png') { |not_found| out.write(not_found.read) }
              end
            else
              puts("writing #{entry.name} as-is")
              out.put_next_entry(entry.name)
              out.write(entry.get_input_stream.read)
            end
          end
          zipfile.close
        end
        buffer.string
      end
    end
  end
end
