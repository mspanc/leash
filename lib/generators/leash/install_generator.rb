require 'rails/generators/base'

module Devise
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a Leash initializer and copy locale files to your application."

      def copy_initializer
        template "leash.rb", "config/initializers/leash.rb"
      end
    end
  end
end