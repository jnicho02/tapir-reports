$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'tapir/reports'

def fixture name
  File.join(File.dirname(__FILE__), '..', 'fixtures', name)
end
