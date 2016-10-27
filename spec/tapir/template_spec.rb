require 'spec_helper'

describe Tapir::Reports::Template do
  context "given an OpenOffice template" do
    let(:template) { Tapir::Reports::Template.new(fixture('variables.odt')) }
    it "should recognise the extension" do
      expect(template.extension).to eq 'odt'
    end

    it "should process a document with simple variable substitution" do
      json_string = '{"person":"Jeff", "lastname":"Durand", "address": { "street":"22 charlotte rd", "zipcode":"01013", "residents": 3 }}'
      expect(template.process(json_string)).to include('Hello Jeff')
    end
  end

  context "given a Word template" do
    let(:template) { Tapir::Reports::Template.new(fixture('variables.docx')) }
    it "should recognise the extension" do
      expect(template.extension).to eq "docx"
    end

    it "should process a document with simple variable substitution" do
      json_string = '{"person":"Jeff", "lastname":"Durand", "address": { "street":"22 charlotte rd", "zipcode":"01013", "residents": 3 }}'
      expect(template.process(json_string)).to include('Hello Jeff')
    end
  end

end
