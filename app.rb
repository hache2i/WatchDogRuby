require 'sinatra/base'
require 'sinatra/contrib'
require 'mongoid'
require 'logger'
require 'json'

$LOAD_PATH.push(File.expand_path(File.join(File.dirname(__FILE__), './')))

require_relative './lib/notifier'
require_relative './wddomain/lib/threads'
require_relative './wddomain/lib/watchdog_domain'
require_relative './wddomain/lib/domain_data'
require_relative './users/lib/users_domain_exception'
require_relative './files/lib/changed'
require_relative './actions/get_pending_proposals'

require_relative 'base_app'
require_relative 'login'

require_relative 'lib/activation'
require_relative 'lib/google_authentication'

class Web < BaseApp

  helpers Sinatra::Activation
  helpers Sinatra::GoogleAuthentication

  set :public_folder, './public'
  set :static, true

  before do
    p "APP BEFORE"
    require_authentication
    @domain = get_domain
    @userEmail = get_user_email
    require_activation
    redirect '/notDomainAdmin' if !Watchdog::Global::Watchdog.isAdmin @userEmail
  end

  get '/index.html' do
    erb :index, :layout => :home_layout
  end

  get '/' do
    @message = Notifier.message_for params['alert_signal']
    erb :index, :layout => :home_layout
  end

  get '/users' do
    WDLogger.debug "Getting Users"
    begin
      @users = Watchdog::Global::Watchdog.getUsers @userEmail, @domain
      erb :users, :layout => :home_layout
    rescue UsersDomainException => e
      showError 'users.domain.exception'
    end
  end

  get '/discover' do
    erb :discover, :layout => :home_layout
  end

  get '/common-folders-page' do
    erb :common_folders, :layout => :home_layout
  end

  post '/child-folders' do
    WDLogger.debug "Getting Files to Change"
    docaccount = Watchdog::Global::Watchdog.getDocsAdmin(@domain)
    usersToProcces = strToArray(params['sortedIdsStr'])

    Thread.abort_on_exception = true
    thr = Thread.new {
      domain_data = DomainData.new @domain, docaccount
      Watchdog::Global::Watchdog.files_under_common_structure usersToProcces, domain_data
    }
    thr[:name] = "child-folders process started at #{Time.now.to_s}"
    Watchdog::Global::Threads.add thr
    thr.join
    redirect "/domain/"
  end

  get '/changed' do
    erb :changed_page, :layout => :home_layout
  end

  get '/pending' do
    erb :pending_page, :layout => :home_layout
  end

  post '/get-proposals' do
    WDLogger.debug "Getting Change Proposals"

    usersToProcces = strToArray(params['sortedIdsStr'])

    pending_files = Wd::Actions::GetPendingProposals.do usersToProcces
    @files = pending_files.values.flatten

    erb :proposals, :layout => :home_layout
  end

  def showError(messageKey)
    @message = Notifier.message_for messageKey
    erb :index, :layout => :home_layout
  end

  def strToArray(usersStr)
    return [] if usersStr.nil?
    usersStr.split(',')
  end

end
