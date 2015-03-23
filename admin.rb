require 'sinatra/base'
require 'sinatra/contrib'
require_relative 'base_app'
require_relative 'lib/notifier'
require_relative './wdconfig/lib/config_domain'

$LOAD_PATH.push(File.expand_path(File.join(File.dirname(__FILE__), '../')))

class Admin < BaseApp

	get '/' do
		erb :admin, :layout => :home_layout
	end

	get '/activateDomain' do
		erb :add_domain, :layout => :home_layout
	end

	post '/activateDomain' do
		begin
			domain = params['domain']
			licenses = params['licenses']
			Watchdog::Global::Domains.activate domain, licenses
			redirect '/admin/listDomains'
		rescue DomainNotSpecifiedException => e 
			errorOnActivation 'activate.domain.domain.required'
		rescue LicensesNotSpecifiedException => e 
			errorOnActivation 'activate.domain.licenses.required'
		end
	end

	def errorOnActivation(messageKey)
		@message = Notifier.message_for messageKey
		erb :add_domain, :layout => :home_layout
	end

	get '/jobs' do
		@jobs = Watchdog::Global::Watchdog.getJobs
		erb :jobs, :layout => :home_layout
	end

	get '/log' do
		@log = Watchdog::Global::Watchdog.getLog
		erb :log, :layout => :home_layout
	end

	get '/exec-log' do
		@records = []
		erb :log, :layout => :home_layout
	end

	get '/exec-log-records', :provides => :json do
		debug = params[:debug]
		p debug
		count = params[:count] && params[:count].to_i
		p count
		from = params[:from] && params[:from].to_i
		records = { records: [], count: 0, from_scratch: true }
		records = Watchdog::Global::Logs::Execution.get if from.nil? || from == 0
		records = Watchdog::Global::Logs::Execution.get_from(from, count) unless from.nil? || from == 0
		records.to_json
	end

	post '/reactivateDomain' do
		domain = params['domain']
		Watchdog::Global::Domains.reactivate domain
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