$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'tapir/reports'

Dir["#{File.dirname(__FILE__)}/support/*.rb"].sort.each { |f| require f }

def fixture(name)
  File.join(File.dirname(__FILE__), '..', 'fixtures', name)
end

def fixture_text(name)
  File.read(fixture(name))
end
