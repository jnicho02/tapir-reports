# Tapir::Reports

This gem is created by report generation professional Jez Nicholson. He has created report builder systems used by environmental consultancies in the UK for the past 13 years. His software has generated over 1 million professional paid-for report documents.

When you want to generate a pdf or Word document populated with data then the normal method is use of a DSL to specify it in code. This can cause a bottleneck at the Developer and be unfriendly to the Product Manager trying to create a report. Sometimes a preferably approach is to create a template document containing markup and mash this with the data.

This gem enables you to write standard ruby erb templating code embedded inside Word documents. My experience at writing document templaters has shown me that you start by inventing your own simple tagging language. This gets more complicated as you add more features (e.g. repeating sections) and it is inflexible. However, like writing html pages I would advise that the 'heavy lifting' is done in your ruby code and not the front-end...but if you insist, then you can.

All work is done in memory so that processing can be run on a cloud platform.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tapir-reports'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tapir-reports

## Usage

Okay, so this is a very early version and the usage may change. Do not use in anger yet!

e.g. A Word document with two images with alt text of '@kitten' and '@kitten2'. Also with text of 'Hello <%= person %>'

```
  template = Tapir::Reports::Template.new(File.read('images.docx'))
  json_string =
    '{
      "person":"Jez",
      "lastname":"Nicholson",
        "address": {
          "street":"somewhere",
          "town":"Brighton"
        }
    }'
  replacements =
    [
      ['@kitten', File.read('193px-Stray_kitten_Rambo001.jpg')],
      ['@kitten2', File.read('reclining-kitten.jpg')],
    ]
  template.output(json_string, replacements, 'altered-images.docx')
```
generates a document with 'Hello Jez' and the images changed to the images provided.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jnicho02/tapir-reports. Companies may sponsor a feature request by contacting Jez at TapirTech.
