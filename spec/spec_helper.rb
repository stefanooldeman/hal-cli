require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, :test)

require './app'

RSpec.configure do |config|

  config.expect_with :rspec do |c|
    c.syntax = [:expect]
  end
  config.before(:suite) do
  end
end
