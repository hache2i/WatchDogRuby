require 'sinatra/base'
require 'sinatra/contrib'
require_relative 'base_app'
require_relative '../wdconfig/lib/config_domain'

$LOAD_PATH.push(File.expand_path(File.join(File.dirname(__FILE__), '../')))

class Admin < BaseApp

	get '/' do
		erb :admin, :layout => :home_layout
	end

	get '/activateDomain' do
		erb :add_domain, :layout => :home_layout
	end

	post '/activateDomain' do
		domain = params['domain']
		Watchdog::Global::Domains.activate domain
		redirect '/admin/listDomains'
	end

	get '/listDomains' do
		@domains = Watchdog::Global::Domains.list
		@inactive = Watchdog::Global::Domains.inactive
		erb :domains, :layout => :home_layout
	end

	post '/desactivateDomain' do
		Watchdog::Global::Domains.desactivate params['domain']
		configDomain = WDConfig::ConfigDomain.new
		configDomain.unschedule params['domain'] if configDomain.hasScheduled?(params['domain'])
		redirect '/admin/listDomains'
	end

  	def self.new(*)
		app = Rack::Auth::Digest::MD5.new(super) do |username|
		  {'foo' => 'bar'}[username]
		end
		app.realm = 'Protected Area'
		app.opaque = 'secretkey'
		app
	end
end