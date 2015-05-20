require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'active_support'

require './lib/client'
require './lib/fsm'

require 'net/http'
require 'uri'
