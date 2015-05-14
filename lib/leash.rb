require "rails"
require "devise"
require "ohm"
require "leash/version"
require "leash/engine"
require "leash/routing"

module Leash
  mattr_accessor :user_roles
  @@user_roles = []

  mattr_accessor :redis_url
  @@redis_url = "redis://127.0.0.1:6379/0"


  mattr_accessor :reuse_access_tokens
  @@reuse_access_tokens = true


  def self.configure
    yield self
  end


  def self.establish_connection!
    Ohm.redis = Redic.new(@@redis_url)
  end
end