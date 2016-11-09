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

  context "given a Docx template" do
    let(:template) { Tapir::Reports::Template.new(fixture('variables.docx')) }

    it "should be return a working document" do
      template.output(json_string,fixture('193px-Stray_kitten_Rambo001.jpg'))
      expect(fixture('mangled.docx')).to zip_entry_contains('word/document.xml', 'Hello Jez')
    end
  end

end
