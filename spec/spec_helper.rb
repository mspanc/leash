require 'rubygems'
require 'bundler/setup'

require 'combustion'
require 'factory_girl_rails'

Combustion.initialize! :action_controller, :active_record

FactoryGirl.define do
  factory :admin do
    sequence :email do |n| 
      "admin#{n}@example.com"
    end
    
    confirmed_at { Time.now }
    password "qwerty123"
  end
end

require 'rspec/rails'

RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
  config.include FactoryGirl::Syntax::Methods
  config.use_transactional_fixtures = true

  config.before(:suite) do
    Ohm.redis.call "FLUSHALL"
  end
end