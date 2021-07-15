require 'spec_helper'

describe Tapir::Reports::Template do
  context 'given a single line containing a loop' do
    let(:content) {
      '<w:r w:rsidRPr=\"00CC6674\"><w:t>&lt;%= @</w:t></w:r><w:proofErr w:type=\"gramStart\"/><w:r w:rsidRPr=\"00CC6674\"><w:t>model.inclusions</w:t></w:r><w:proofErr w:type=\"gramEnd\"/><w:r w:rsidRPr=\"00CC6674\"><w:t>.prioritised.each do |</w:t></w:r><w:proofErr w:type=\"spellStart\"/><w:r w:rsidRPr=\"00CC6674\"><w:t>inc</w:t></w:r><w:proofErr w:type=\"spellEnd\"/><w:r w:rsidRPr=\"00CC6674\"><w:t>| %</w:t></w:r><w:r w:rsidR=\"00CC6674\" w:rsidRPr=\"00CC6674\"><w:t>&gt;&lt;%= inc.name %&gt;&lt;% end %&gt;</w:t></w:r>'
    }
    it 'should turn it into a clean piece of erb' do
      puts Tapir::Reports::Template.to_erb(content)
      expect(Tapir::Reports::Template.to_erb(content)).to eq('<w:r w:rsidRPr=\"00CC6674\"><w:t><%= @model.inclusions.prioritised.each do |inc| %><%= inc.name %><% end %></w:t></w:r>')
    end
  end
end
