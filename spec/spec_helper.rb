ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec'
require 'rspec/rails'
require 'rspec/autorun'
require 'ffaker'

# Require support files
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|

  config.mock_with :rr

  config.before :each do
    Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
  end

  config.include Devise::TestHelpers, :type => :controller

end

CarrierWave.configure do |config|
  config.storage = :file
  config.enable_processing = false
end

