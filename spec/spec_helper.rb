if RUBY_VERSION >= '1.9'
	require 'simplecov'
	require 'coveralls'
	SimpleCov.formatters = [SimpleCov::Formatter::HTMLFormatter, Coveralls::SimpleCov::Formatter]
	SimpleCov.start do
		add_filter '/spec'
		#minimum_coverage(90)
	end
end
require 'rubygems'
require 'bundler'
require 'rack/test'
require 'rspec'
require 'rack/test'
require 'omniauth'
require 'omniauth/test'

Bundler.setup :default, :development, :test

require 'rack/test'
require 'omniauth/remote-user'

RSpec.configure do |config|
	config.include Rack::Test::Methods
	config.extend OmniAuth::Test::StrategyMacros, :type => :strategy
end
