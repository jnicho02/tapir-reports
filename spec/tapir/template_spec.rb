require 'spec_helper'

describe Tapir::Reports::Template do
  let(:person){ JSON.parse('{
      "firstname":"Jez",
      "lastname":"Nicholson",
      "address": {
        "street":"somewhere",
        "town":"Brighton"
      }
    }', object_class: OpenStruct)
  }

  context "given a document with variable tags in" do
    let(:template) { Tapir::Reports::Template.new(fixture('variables.docx')) }
    it "should return a working document" do
      s = template.output(binding, [])
#      expect(s).to include('Hello Jez')
    end
    it "should replace erb variables with bound variable values" do
      s = template.render(binding)
      expect(s).to include('Hello Jez')
    end
  end

  context "given a document with variable tags in with extra messy Word tags" do
    let(:template) { Tapir::Reports::Template.new(fixture('messytags.docx')) }
    it "should be return a working document" do
      s = template.render(binding)
      expect(s).to include('Hello Jez')
    end
  end

  context "given a more complicated document" do
    let(:template) { Tapir::Reports::Template.new(fixture('products.docx')) }
    it "should be return a working document" do
      @title = "Product Report"
      hashh =[ { name: "olives" }, { name: "peaches" } ]
      @products = JSON.parse(hashh.to_json, object_class: OpenStruct)
      s = template.render(binding)
      expect(s).to include('olives, peaches')
    end
  end

  context "given an object containing products as input" do
    let(:template) { Tapir::Reports::Template.new(fixture('products.docx')) }
    it "should be return a working document" do
      a = Product.new
      a.name = "apples"
      b = Product.new
      b.name = "bananas"
      @products = [a,b]
      s = template.render(binding)
      expect(s).to include('apples, bananas')
    end
  end

  context "given an object as input and ruby in the template" do
    let(:template) { Tapir::Reports::Template.new(fixture('products_with_ruby.docx')) }
    it "should be return a working document" do
      a = Product.new
      a.name = "apples"
      b = Product.new
      b.name = "bananas"
      @products = [a,b]
      s = template.render(binding)
      expect(s).to include('oranges, bananas')
    end
  end

end

class Product
  attr_accessor :name, :price
end
