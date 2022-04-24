require 'spec_helper'

describe Tapir::Reports::Template do
  let(:kitten_photo) { fixture('193px-Stray_kitten_Rambo001.jpg') }

  context 'given a document with images in' do
    # let(:template) { Tapir::Reports::Template.new(fixture('images.docx')) }
    let(:template) { Tapir::Reports::Template.new(fixture('FloodSmart_Standard_Jan2022_v1.1.docx')) }

    it 'should return the first kitten relationship_id' do
      expect(template.relationship_id('@kitten')).to eq 'rId4'
    end

    it 'should return the second kitten relationship_id' do
      expect(template.relationship_id('@kitten2')).to eq 'rId5'
    end

    it 'should return the first kitten url' do
      expect(template.url('rId4')).to eq 'word/media/image1.jpg'
    end

    it 'should be return a working document' do
      replacements =
        [
          ['@kitten', fixture('193px-Stray_kitten_Rambo001.jpg')],
          ['@kitten2', 'http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_SitePlan.jpg']
        ]
      template.output(binding, replacements)
    end

    it 'should complain about missing images' do
      replacements =
        [
          ['@kitten', fixture('193px-Stray_kitten_Rambo001.jpg')]
        ]
      template.output(binding, replacements)
    end

    it 'should be okay with extra images' do
      replacements =
        [
          ['@kitten', 'http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_AerialImage.jpg'],
          ['@kitten2', 'http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_SitePlan.jpg'],
          ['@kitten3', 'http://storage.googleapis.com/geosmart-orders/51402/Maps/51402_SitePlanxxxx.jpg']
        ]
      s = template.output(binding, replacements)
      File.open("fixtures/mangled_images.docx", "wb") { |f| f.write(s) }
    end

    it 'should be okay about missing images' do
      replacements =
        [
          ['@kitten', fixture('193px-Stray_kitten_DoesNotExist.jpg')]
        ]
      s = template.output(binding, replacements)
      File.open('fixtures/missing_image.docx', "wb") { |f| f.write(s) }
    end
  end
end
