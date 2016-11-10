require 'spec_helper'

describe Tapir::Reports::Template do
  let(:json){ JSON.parse('{
      "person":"Jez",
      "lastname":"Nicholson",
      "address": {
        "street":"somewhere",
        "town":"Brighton"
      }
    }', object_class: OpenStruct)
  }

  context "given clean document.xml with variables tags in" do
    let(:template) { Tapir::Reports::Template.new(fixture('variables.docx')) }
    let(:content) { fixture_text('variables_docx/word/document.xml') }

    it "should replace an erb tag with data" do
      expect(template.render(json, content)).to include('Hello Jez')
    end
  end

end
