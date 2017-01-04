require 'spec_helper'

describe Tapir::Reports::Template do
  let(:kitten_photo){ fixture('193px-Stray_kitten_Rambo001.jpg') }

  context "given a document with images in" do
    let(:template) { Tapir::Reports::Template.new(fixture('images.docx')) }

    it "should find first kitten image" do
      expect(template.image_names[0]).to eq '@kitten'
    end

    it "should find second kitten image" do
      expect(template.image_names[1]).to eq '@kitten2'
    end

    it "should return the first kitten relationship_id" do
      expect(template.relationship_id('@kitten')).to eq 'rId4'
    end

    it "should return the second kitten relationship_id" do
      expect(template.relationship_id('@kitten2')).to eq 'rId5'
    end

    it "should return the first kitten url" do
      expect(template.url('rId4')).to eq 'word/media/image1.jpg'
    end

    it "should be return a working document" do
      json_string = '{}'
      replacements =
        [
          ['@kitten', fixture('193px-Stray_kitten_Rambo001.jpg')],
          ['@kitten2', fixture('reclining-kitten.jpg')],
        ]
      template.write_to_file(json_string, replacements, 'altered-images.docx')
#      expect(fixture('mangled.docx')).to zip_entry_contains('word/document.xml', 'Hello Jez')
    end

  end

end
