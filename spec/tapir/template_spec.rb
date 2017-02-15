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

  context "given a document with variable tags in" do
    let(:template) { Tapir::Reports::Template.new(fixture('variables.docx')) }

    it "should be return a working document" do
      replacements = []
      template.write_to_file(json_string, replacements, 'mangled.docx')
      expect(fixture('mangled.docx')).to zip_entry_contains('word/document.xml', 'Hello Jez')
    end
  end

  context "given a document with variable tags in with extra messy Word tags" do
    let(:template) { Tapir::Reports::Template.new(fixture('messytags.docx')) }

    it "should be return a working document" do
      replacements = []
      template.write_to_file(json_string, replacements, 'mangled_messytags.docx')
      expect(fixture('mangled_messytags.docx')).to zip_entry_contains('word/document.xml', 'Hello Jez')
    end
  end

  context "given a more complicated document" do
    let(:template) { Tapir::Reports::Template.new(fixture('products.docx')) }

    it "should be return a working document" do
      products =
        {
          :title => "Product Report",
          :products => [
            {
              :name => "olives"
            },
            {
              :name => "peaches"
            }
          ]
        }
      template.write_to_file(products.to_json, [], 'mangled_products.docx')
      expect(fixture('mangled_products.docx')).to zip_entry_contains('word/document.xml', 'olives, peaches')
    end
  end

  context "given an object as input" do
    let(:template) { Tapir::Reports::Template.new(fixture('products.docx')) }
    it "should be return a working document" do
      foo = Foo.new
      template.write_to_file(foo, [], 'mangled_products.docx')
      expect(fixture('mangled_products.docx')).to zip_entry_contains('word/document.xml', 'apples, bananas')
    end
  end

  context "given an object as input and ruby in the template" do
    let(:template) { Tapir::Reports::Template.new(fixture('products_with_ruby.docx')) }
    it "should be return a working document" do
      foo = Foo.new
      template.write_to_file(foo, [], 'mangled_products_with_ruby.docx')
#      expect(fixture('mangled_products_with_ruby.docx')).to zip_entry_contains('word/document.xml', 'apples, bananas')
    end
  end
end

class Foo
  def title
    "I am foo!"
  end

  def products
    a = Product.new
    a.name = "apples"
    b = Product.new
    b.name = "bananas"
    [a,b]
  end
end

class Product
  attr_accessor :name, :price
end
