require 'spec_helper'

describe Tapir::Reports::Template do
  context 'given a tag with an angled apostrophe in' do
    let(:content) { '&lt;%= if person.name == ‘Roger‘ %&gt;' }
    it 'should have normal single quotes' do
      expect(Tapir::Reports::Template.to_erb(content)).to eq("<%= if person.name == 'Roger' %>")
    end
  end
end
