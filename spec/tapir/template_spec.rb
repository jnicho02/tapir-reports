require 'spec_helper'

describe Tapir::Reports::Template do
  let(:json_string){ '{
      "person":"Jeff",
      "lastname":"Durand",
      "address": {
        "street":"22 charlotte rd",
        "zipcode":"01013",
        "residents": 3
      }
    }'
  }

  context "given an OpenOffice 4 template" do
    let(:template) { Tapir::Reports::Template.new(fixture('variables.odt')) }
    it "should recognise the extension" do
      expect(template.extension).to eq 'odt'
    end

    it "should replace an erb tag with data" do
      expect(template.process(json_string)).to include('Hello Jeff')
    end
  end

  context "given a Word Docx template" do
    let(:template) { Tapir::Reports::Template.new(fixture('variables.docx')) }
    it "should recognise the extension" do
      expect(template.extension).to eq "docx"
    end

    it "should replace an erb tag with data" do
      expect(template.process(json_string)).to include('Hello Jeff')
    end
  end

end
