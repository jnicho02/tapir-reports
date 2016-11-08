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
  let(:kitten_photo){ fixture('193px-Stray_kitten_Rambo001.jpg') }

  context "given an OpenOffice template" do
    let(:template) { Tapir::Reports::Template.new(fixture('images.odt')) }

    it "should find first kitten image" do
      expect(template.image_names[0]).to eq '@kitten'
    end

    it "should find second kitten image" do
      expect(template.image_names[1]).to eq '@kitten2'
    end
  end

  context "given a Word Docx template" do
    let(:template) { Tapir::Reports::Template.new(fixture('images.docx')) }

    it "should find first kitten image" do
      expect(template.image_names[0]).to eq '@kitten'
    end

    it "should find second kitten image" do
      expect(template.image_names[1]).to eq '@kitten2'
    end

    it "should return a working document" do
      template.output(json_string, kitten_photo)
#      expect(fixture('mangled.docx')).to zip_entry_contains('word/document.xml', 'Hello Jez')
    end
  end

end
