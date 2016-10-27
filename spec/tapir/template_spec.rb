require 'spec_helper'

describe Tapir::Reports::Template do
  let(:json_string){ '{
      "person":"Jez",
      "lastname":"Nicholson",
      "address": {
        "street":"somewhere",
        "town":"Brighton"
      }
    }'
  }

  context "given an OpenOffice 4 template" do
    let(:template) { Tapir::Reports::Template.new(fixture('variables.odt')) }
    it "should recognise the extension" do
      expect(template.extension).to eq 'odt'
    end

    it "should replace an erb tag with data" do
      expect(template.process(json_string)).to include('Hello Jez')
    end

    it "should be return a working document" do
#      template.output(json_string)
#      expect(fixture('mangled.odt')).to zip_entry_contains('content.xml', 'Hello Jez')
    end
  end

  context "given a Word Docx template" do
    let(:template) { Tapir::Reports::Template.new(fixture('variables.docx')) }
    it "should recognise the extension" do
      expect(template.extension).to eq "docx"
    end

    it "should replace an erb tag with data" do
      expect(template.process(json_string)).to include('Hello Jez')
    end

    it "should be return a working document" do
      template.output(json_string)
      expect(fixture('mangled.docx')).to zip_entry_contains('word/document.xml', 'Hello Jez')
    end
  end

end
