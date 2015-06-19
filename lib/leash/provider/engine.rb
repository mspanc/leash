module Leash
  module Provider
    class Engine < ::Rails::Engine
      isolate_namespace Leash::Provider

    end
  end
end
