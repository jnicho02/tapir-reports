require 'spec_helper'

describe Tapir::Reports::Template do
  context "given a clean bit of escaped erb" do
    let(:erb) { '&lt;%= person %&gt;' }

    it "should turn it into a clean piece of erb" do
      expect(Tapir::Reports::Template.sanitize(erb)).to eq("<%= person %>")
    end
  end

  context "given a clean bit of escaped erb with two tags" do
    let(:erb) { '&lt;%= person %&gt; &lt;%= another_person %&gt;' }

    it "should turn it into a clean piece of erb" do
      expect(Tapir::Reports::Template.sanitize(erb)).to eq("<%= person %> <%= another_person %>")
    end
  end

  context "given a messy bit of escaped erb" do
    let(:erb) { '&lt;%=</w:t></w:r><w:r w:rsidR="007A3FBB"><w:rPr><w:lang w:val="en-US"/></w:rPr><w:t xml:space="preserve"> </w:t></w:r><w:r><w:rPr><w:lang w:val="en-US"/></w:rPr><w:t xml:space="preserve">lastname </w:t></w:r><w:bookmarkStart w:id="0" w:name="_GoBack"/><w:bookmarkEnd w:id="0"/><w:r><w:rPr><w:lang w:val="en-US"/></w:rPr><w:t>%&gt;' }

    it "should turn it into a clean piece of erb" do
      expect(Tapir::Reports::Template.sanitize(erb)).to eq("<%= lastname %>")
    end
  end

  context "given a section containing messy bit of escaped erb" do
    let(:erb) { 'aaaaa&lt;%=</w:t></w:r><w:r w:rsidR="007A3FBB"><w:rPr><w:lang w:val="en-US"/></w:rPr><w:t xml:space="preserve"> </w:t></w:r><w:r><w:rPr><w:lang w:val="en-US"/></w:rPr><w:t xml:space="preserve">lastname </w:t></w:r><w:bookmarkStart w:id="0" w:name="_GoBack"/><w:bookmarkEnd w:id="0"/><w:r><w:rPr><w:lang w:val="en-US"/></w:rPr><w:t>%&gt;bbbbb' }

    it "should turn it into a clean piece of erb" do
      expect(Tapir::Reports::Template.sanitize(erb)).to eq("aaaaa<%= lastname %>bbbbb")
    end
  end

end
