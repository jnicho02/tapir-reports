$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'tapir/reports'

Dir[File.dirname(__FILE__) + "/support/*.rb"].each {|f| require f}

def fixture name
  File.join(File.dirname(__FILE__), '..', 'fixtures', name)
end
