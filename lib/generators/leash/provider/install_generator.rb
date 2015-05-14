require 'rails/generators/base'

module Leash
  module Provider
    module Generators
      class InstallGenerator < Rails::Generators::Base
        source_root File.expand_path("../../templates", __FILE__)

        desc "Creates a Leash initializer and route."

        def copy_initializer
          template "leash_provider.rb", "config/initializers/leash_provider.rb"
        end


        def add_route
          route "leash_provicer"
        end
      end
    end
  end
end