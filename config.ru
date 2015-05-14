require 'rubygems'
require 'bundler'

Bundler.require :default, :development

Combustion.initialize! :action_controller, :active_record
run Combustion::Application
