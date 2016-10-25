# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tapir/reports/version'

Gem::Specification.new do |spec|
  spec.name          = "tapir-reports"
  spec.version       = Tapir::Reports::VERSION
  spec.authors       = ["Jez Nicholson"]
  spec.email         = ["jez.nicholson@gmail.com"]

  spec.summary       = %q{Generate professional quality report documents by transforming Word or OpenOffice templates with data}
  spec.description   = %q{This gem follows a simple premise of transforming a template created in a standard word processing package (such as Word) by embedding standard ruby templating language (like erb) inside the document. As the input template is a real document, using the version that you presumably want we don't have to store all the details.
    TapirTech Ltd retain copyright of the gem and allow you to use it on your own project free of charge. You are strongly encouraged to send us your enhancements. Alternatively, you can sponsor and enhancement or you can use our paid-for document generation service. }
  spec.homepage      = "https://github.com/jnicho02/tapir-reports"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
