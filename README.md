# Tapir::Reports

Write erb in Word documents to use them as templates

## History
This gem is created by report generation professional Jez Nicholson.
He has created report builder systems used by environmental consultancies in the
UK for the past 13 years.
His software has generated over 1 million professional paid-for report documents.

## Why?
When you want to generate a pdf or Word document populated with data then the
normal method is use of a DSL to specify it in code.
This can cause a bottleneck at the Developer and be unfriendly to the Product
Manager trying to create a report.
Sometimes a preferably approach is to create a template document containing
markup and mash this with the data.

This gem enables you to write standard ruby erb templating code embedded inside
Word documents.
My experience at writing document templaters has shown me that you start by
inventing your own simple tagging language.
This gets more complicated as you add more features (e.g. repeating sections)
and it is inflexible.
However, like writing html.erb pages I would advise that the 'heavy lifting' is
done in your ruby code and not the front-end...but if you insist, then you can.

All work is done in memory so that processing can be run on a cloud platform.

Word is quite gung-ho at sticking extra xml tags into the document.xml, things
like marking spelling mistakes (which your tagnames may well look like) or
retaining whitespace.
We cope with those by stripping any xml that appears between erb start and end
tags.

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

Okay, so this is a very early version and the usage may change.
Do not use in anger yet!

e.g. A Word document with two images with alt text of '@kitten' and '@kitten2'.
Also with text of 'Hello <%= person %>'

```
  template = Tapir::Reports::Template.new('images.docx')
```
or maybe it is in a Rails app folder?
```
  template = Tapir::Reports::Template.new('app/assets/images/kennel_times.docx')
```
anything that is a variable in the method is accessible from the current 'binder'
object of your class. Pass the binder to tapir-reports and any variable can then
be used in erb in the Word template

Images are currently replaced by setting the alt text in Word to a value, e.g.
'@kitten2' which matches the array of image_replacements. This suxx, and I will
be rewriting this next. I will probably let you declare an image_tag in the alt
text which will then become the main image.
```
  @title = "My document"
  image_replacements =
    [
      ['@kitten', File.read('193px-Stray_kitten_Rambo001.jpg')],
      ['@kitten2', File.read('reclining-kitten.jpg')],
    ]
  s = template.output(binder, image_replacements)
```
You could then write it to a File
```
  File.open("/Users/me/Downloads/my_new_doc.docx", "wb") {|f| f.write(s) }
```
or if you are in Rails you might want to stream it straight back to the user
```
send_data s, filename: "a_new.docx", type: :docx, disposition: :inline
```
if you are streaming it from Rails then you might want to declare the mimetype
so that you can do a respond_to do |format| for .docx
```
Mime::Type.register "application/vnd.openxmlformats-officedocument.wordprocessingml.document", :docx
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jnicho02/tapir-reports. Companies may sponsor a feature request by contacting Jez at TapirTech.
