require 'sinatra/base'
require 'sinatra/contrib'
require 'mongoid'
require 'logger'
require 'json'

$LOAD_PATH.push(File.expand_path(File.join(File.dirname(__FILE__), './')))

require_relative './lib/notifier'
require_relative './wddomain/lib/watchdog_domain'
require_relative './wddomain/lib/domain_data'
require_relative './wdconfig/lib/timing_not_specified_exception'
require_relative './wdconfig/lib/docsowner_not_specified_exception'
require_relative './users/lib/users_domain_exception'
require_relative './files/lib/changed'
require_relative './files/lib/changed'
require_relative './actions/get_pending_proposals'
require_relative './actions/get_pending_files_count'
require_relative './actions/get_pending_files'
require_relative './actions/get_common_folders'
require_relative './actions/change_all_pending_files'
require_relative './actions/change_pending_file'

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
    WDLogger.info "Getting Users"
    begin
      @users = Watchdog::Global::Watchdog.getUsers @userEmail, @domain
      erb :users, :layout => :home_layout
    rescue UsersDomainException => e
      showError 'users.domain.exception'
    end
  end

  get '/api/users', provides: :json do
    users = Watchdog::Global::Watchdog.getUsers @userEmail, @domain
    users_data = users.map do |user|
      { email: user.email, name: user.name }
    end
    users_data.to_json
  end

  get '/discover' do
    erb :discover, :layout => :home_layout
  end

  get '/common-folders-page' do
    erb :common_folders, :layout => :home_layout
  end

  get '/common-folders', :provides => :json do
    docaccount = Watchdog::Global::Watchdog.getDocsAdmin(@domain)
    common_folders =  Wd::Actions::GetCommonFolders.do docaccount
    common_folders.to_json
  end

  post '/child-folders' do
    WDLogger.info "Getting Files to Change"
    docaccount = Watchdog::Global::Watchdog.getDocsAdmin(@domain)
    usersToProcces = strToArray(params['sortedIdsStr'])

    Thread.abort_on_exception = true
    thr = Thread.new {
      domain_data = DomainData.new @domain, docaccount
      Watchdog::Global::Watchdog.files_under_common_structure usersToProcces, domain_data
    }
    redirect "/domain/"
  end

  get '/pending' do
    erb :pending_page, :layout => :home_layout
  end

  get '/pending/count', :provides => :json do
    WDLogger.info "Getting Pending Files Count"

    pending_files_count = Wd::Actions::GetPendingFilesCount.do @domain

    pending_files_count.to_json
  end

  post '/pending/files', :provides => :json do
    WDLogger.info "Getting Pending Files"
    p "Getting Pending Files"
    from = params[:from].to_i

    access_data = { userEmail: @userEmail, domain: @domain }
    files = Wd::Actions::GetPendingFiles.do from, nil, access_data

    files.to_json
  end

  post '/pending/change/all', :provides => :json do
    WDLogger.info "Changing permission for all pending files"

    Thread.new {
      Wd::Actions::ChangeAllPendingFiles.do @domain
    }

    { msg: "yeah" }.to_json
  end

  post '/pending/change', :provides => :json do
    WDLogger.info "Changing permission for a pending file"
    Wd::Actions::ChangePendingFile.do params[:permissionId], @domain
    { msg: "yeah" }.to_json
  end

  post '/get-proposals' do
    WDLogger.info "Getting Change Proposals"

    usersToProcces = strToArray(params['sortedIdsStr'])

    pending_files = Wd::Actions::GetPendingProposals.do usersToProcces
    @files = pending_files.values.flatten

    erb :proposals, :layout => :home_layout
  end

  post '/new-change-permissions', :provides => :json do
    WDLogger.info 'Change Permissions'
    files = JSON.parse(params['files'])
    files_to_change = Files::FilesToChange.group_by_user files

    Thread.new{
      Watchdog::Global::Watchdog.changePermissions(files_to_change, @domain)
    }

    { :msg => "yeah" }.to_json
  end

  get '/changed-page' do
    WDLogger.info "Changed Page"
    erb :changes_log, :layout => :home_layout
  end

  get '/changed', :provides => :json do
    WDLogger.info 'Changed Files'
    Files::Changed.where(:domain => @domain).limit(100).desc(:executed).to_json
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
