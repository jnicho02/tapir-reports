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

  context "given a document with variable tags in" do
    let(:template) { Tapir::Reports::Template.new(fixture('variables.docx')) }

    it "should be return a working document" do
      replacements = []
      template.output(json_string, replacements, 'mangled.docx')
      expect(fixture('mangled.docx')).to zip_entry_contains('word/document.xml', 'Hello Jez')
    end
  end

  context "given a document with variable tags in with extra messy Word tags" do
    let(:template) { Tapir::Reports::Template.new(fixture('messytags.docx')) }

    it "should be return a working document" do
      replacements = []
      template.output(json_string, replacements, 'mangled_messytags.docx')
      expect(fixture('mangled_messytags.docx')).to zip_entry_contains('word/document.xml', 'Hello Jez')
    end
  end

end
