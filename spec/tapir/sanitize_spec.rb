require 'spec_helper'

describe Tapir::Reports::Template do
  context "given a clean bit of escaped content" do
    let(:content) { '&lt;%= person %&gt;' }
    it "should turn it into a clean piece of erb" do
      expect(Tapir::Reports::Template.to_erb(content)).to eq("<%= person %>")
    end
  end

  context "given a clean bit of escaped content with two tags" do
    let(:content) { '&lt;%= person %&gt; &lt;%= another_person %&gt;' }
    it "should turn it into a clean piece of erb" do
      expect(Tapir::Reports::Template.to_erb(content)).to eq("<%= person %> <%= another_person %>")
    end
  end

  context "given a messy bit of escaped content" do
    let(:content) { '&lt;%=</w:t></w:r><w:r w:rsidR="007A3FBB"><w:rPr><w:lang w:val="en-US"/></w:rPr><w:t xml:space="preserve"> </w:t></w:r><w:r><w:rPr><w:lang w:val="en-US"/></w:rPr><w:t xml:space="preserve">lastname </w:t></w:r><w:bookmarkStart w:id="0" w:name="_GoBack"/><w:bookmarkEnd w:id="0"/><w:r><w:rPr><w:lang w:val="en-US"/></w:rPr><w:t>%&gt;' }
    it "should turn it into a clean piece of erb" do
      expect(Tapir::Reports::Template.to_erb(content)).to eq("<%= lastname %>")
    end
  end

  context "given a section containing messy bit of escaped content" do
    let(:content) { 'aaaaa&lt;%=</w:t></w:r><w:r w:rsidR="007A3FBB"><w:rPr><w:lang w:val="en-US"/></w:rPr><w:t xml:space="preserve"> </w:t></w:r><w:r><w:rPr><w:lang w:val="en-US"/></w:rPr><w:t xml:space="preserve">lastname </w:t></w:r><w:bookmarkStart w:id="0" w:name="_GoBack"/><w:bookmarkEnd w:id="0"/><w:r><w:rPr><w:lang w:val="en-US"/></w:rPr><w:t>%&gt;bbbbb' }
    it "should turn it into a clean piece of erb" do
      expect(Tapir::Reports::Template.to_erb(content)).to eq("aaaaa<%= lastname %>bbbbb")
    end
  end

  context "given a section containing messy content" do
    let(:content) {
      '<w:p w14:paraId="5CCCF739" w14:textId="77777777" w:rsidR="001B6789" w:rsidRDefault="001B6789"><w:pPr><w:pStyle w:val="BlockText"/></w:pPr><w:r><w:t xml:space="preserve">&lt;%</w:t></w:r><w:proofErr w:type="spellStart"/><w:proofErr w:type="gramStart"/><w:r><w:t> products.each</w:t></w:r><w:proofErr w:type="spellEnd"/><w:proofErr w:type="gramEnd"/><w:r><w:t xml:space="preserve"> do </w:t></w:r><w:r w:rsidR="00F465CA"><w:t xml:space="preserve">|product| %&gt;&lt;%= product.name %&gt;, &lt;% end %&gt;</w:t></w:r></w:p>'
    }
    it "should turn it into a clean piece of content" do
      expect(Tapir::Reports::Template.to_erb(content)).to eq('<w:p w14:paraId="5CCCF739" w14:textId="77777777" w:rsidR="001B6789" w:rsidRDefault="001B6789"><w:pPr><w:pStyle w:val="BlockText"/></w:pPr><w:r><w:t xml:space="preserve"><% products.each do |product| %><%= product.name %>, <% end %></w:t></w:r></w:p>')
    end
  end
end
