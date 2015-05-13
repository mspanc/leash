Leash.configure do |config|

  ### ==> User classes
  ## Allowed user classes. Please create devise models with such names first.
  ## None by default so you have to set it to something meaningful in order
  ## to use Leash.  
  config.user_classes = [ "User", "Admin" ]


  ### ==> Redis
  ## Redis database address. Will use redis://localhost:6379/0 by default.
  ## Leash internally uses Ohm gem for encapsulating redis data into models.
  ## At the moment this setting will be shared with all Ohm models, so
  ## if you use any other Ohm models in the app and they need to use different
  ## database, you must hack the gem.
  ##
  ## If you need to initialize connection to redis database specified below,
  ## e.g. in unicorn or puma initializer please use the following syntax: 
  ## Leash.establish_connection!
  # config.redis_url = "redis://127.0.0.1:6379/0"

end