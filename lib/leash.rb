require "rails"
require "ohm"
require "leash/version"
require "leash/engine"
require "leash/routing"

module Leash
  mattr_accessor :user_classes
  @@user_classes = []

  mattr_accessor :redis_url
  @@redis_url = "redis://127.0.0.1:6379/0"


  def self.configure
    yield self
  end


  def self.establish_connection!
    Ohm.redis = Redic.new(@@redis_url)
  end
end