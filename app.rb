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

  get '/config' do
    executionConfig = Watchdog::Global::Watchdog.getScheduledExecutionConfig(@domain)
    @timing = executionConfig.getTiming
    @newOwner = executionConfig.getDocsOwner
    @scheduled = executionConfig.scheduled?
    erb :config, :layout => :home_layout
  end

  post '/config' do
    begin
      Watchdog::Global::Watchdog.configScheduledExecution(@domain, @userEmail, params['newOwner'], params['timing'])
      @message = Notifier.message_for 'config.saved'
    rescue TimingNotSpecifiedException => e
      showError 'scheduled.execution.config.timing.required'
    rescue DocsownerNotSpecifiedException => e
      showError 'scheduled.execution.config.docsowner.required'
    end
    erb :index, :layout => :home_layout
  end

  post '/scheduleOnce' do
    puts "running once for " + @domain
    Watchdog::Global::Watchdog.scheduleOnce(@domain, @userEmail, params['newOwner'])
    erb :index, :layout => :home_layout
  end

  get '/unschedule' do
    executionConfig = Watchdog::Global::Watchdog.unschedule(@domain)
    @timing = executionConfig.getTiming
    @newOwner = executionConfig.getDocsOwner
    @scheduled = executionConfig.scheduled?
    erb :config, :layout => :home_layout
  end

  get '/users' do
    logger.info "getting users"
    begin
      @users = Watchdog::Global::Watchdog.getUsers @userEmail
      erb :users, :layout => :home_layout
    rescue UsersDomainException => e
      showError 'users.domain.exception'
    end
  end

  post '/child-folders' do
    docaccount = getOwnerByDomain
    usersToProcces = strToArray(params['sortedIdsStr'])
    Thread.abort_on_exception = true
    thr = Thread.new {
      domain_data = DomainData.new @domain, docaccount
      Watchdog::Global::Watchdog.files_under_common_structure usersToProcces, domain_data
    }
    @files = []
    erb :child_files, :layout => :home_layout
  end

  post '/get-proposals' do
    logger.info "Getting proposals"
    usersToProcces = strToArray(params['sortedIdsStr'])
    proposed_change_files = usersToProcces.inject([]) do |files, user|
      user_files = Files::Changed.pending_for_user user
      files.concat user_files
    end
    @files = proposed_change_files
    erb :proposals, :layout => :home_layout
  end

  post '/new-change-permissions', :provides => :json do
    p 'Give Ownership to central account'
    files = JSON.parse(params['files'])
    files_to_change = Files::FilesToChange.group_by_user files

    Watchdog::Global::Watchdog.changePermissions(files_to_change, @domain)
    { :msg => "yeah" }.to_json
  end

  get '/changed-page' do
    p "Changed Page"
    erb :changes_log, :layout => :home_layout
  end

  get '/changed', :provides => :json do
    p 'Changed'
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

  def getOwnerByDomain
    return 'admincloud@cfarco.com' if @domain == 'cfarco.com'
    return 'documentation@watchdog.h2itec.com' if @domain == 'watchdog.h2itec.com'
    return 'documentacion@lfp.es' if @domain == 'lfp.es'
    raise Exception.new("unknown domain")
  end
end
