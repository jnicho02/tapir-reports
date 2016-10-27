# encoding: utf-8

require 'zip'

module Tapir
  module Reports
    RSpec::Matchers.define :zip_entry_contains do |entry, expected|

      match do |actual|
        content = Zip::File.open(actual) { |zipfile| zipfile.read(entry) }
        content.force_encoding("UTF-8")
        content =~ Regexp.new(".*#{Regexp.escape(expected)}.*")
      end

      failure_message do |actual|
        "expected #{actual} to contain the text #{expected}"
      end

      failure_message_when_negated do |actual|
        "expected #{actual} to not contain the text #{expected}"
      end

    end
  end
end
