require 'sinatra/base'
require 'sinatra/contrib'
require_relative 'base_app'
require_relative 'lib/notifier'
require_relative './wdconfig/lib/config_domain'

require_relative './actions/activate_domain'

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
			docs_admin = params['docs_admin']
			domain = params['domain']
			licenses = params['licenses']
			Wd::Actions::ActivateDomain.do domain, docs_admin, licenses
			redirect '/admin/listDomains'
		rescue DomainNotSpecifiedException => e 
			errorOnActivation 'activate.domain.domain.required'
		rescue LicensesNotSpecifiedException => e 
			errorOnActivation 'activate.domain.licenses.required'
		rescue ActivateDomainWrongParams => e 
			errorOnActivation e.message
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
		total_at_time = params[:totalRecordsAtTime] && params[:totalRecordsAtTime].to_i
		from = params[:from] && params[:from].to_i
		refresh = params[:refresh] == true.to_s
		records = { records: [], total_at_time: 0, from_scratch: true }
		records = Watchdog::Global::Logs::Execution.get if from.nil? || from == 0 || refresh
		records = Watchdog::Global::Logs::Execution.get_from(from, total_at_time) unless from.nil? || from == 0 || refresh
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