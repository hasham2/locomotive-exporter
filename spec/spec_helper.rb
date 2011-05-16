ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Require support files
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

Spec::Runner.configure do |config|

  config.mock_with :rr

  config.before :all do
    Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
  end

end

