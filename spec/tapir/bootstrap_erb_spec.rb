require 'spec_helper'

describe Tapir::Reports::Template do
  context 'given an object attribute tag' do
    let(:content) { '&lt;%= @foo.bar %&gt;' }
    it 'should output Twitter Bootstrapped erb (for displaying as a preview)' do
      expect(Tapir::Reports::Template.to_bootstrap_erb(content)).to eq('<%= @foo.bar %>')
    end
  end

  context 'given a Word template' do
    let(:template) { Tapir::Reports::Template.new(fixture('products.docx')) }
    it 'should output Twitter Bootstrapped erb (for displaying as a preview)' do
      html_erb = Tapir::Reports::Template.to_bootstrap_erb(template.contents)
      # File.write('doc.html.erb', html_erb.force_encoding('UTF-8')) # for debug purposes
      expect(html_erb).to include('<link href="https://cdn.jsdelivr.net/npm/bootstrap')
    end
  end
end
