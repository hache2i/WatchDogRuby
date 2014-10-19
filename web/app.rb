require 'sinatra/base'
require 'sinatra/contrib'
require 'mongoid'
require 'logger'
require 'json'

$LOAD_PATH.push(File.expand_path(File.join(File.dirname(__FILE__), '../')))

require_relative './lib/notifier'
require_relative '../wddomain/lib/watchdog_domain'
require_relative '../wdconfig/lib/timing_not_specified_exception'
require_relative '../wdconfig/lib/docsowner_not_specified_exception'
require_relative '../users/lib/users_domain_exception'

require_relative 'base_app'
require_relative 'login'

require_relative 'lib/activation'
require_relative 'lib/google_authentication'

class Web < BaseApp

  helpers Sinatra::Activation
  helpers Sinatra::GoogleAuthentication

  set :public_folder, './web/public'
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
    begin
      @users = Watchdog::Global::Watchdog.getUsers @userEmail
      erb :users, :layout => :home_layout
    rescue UsersDomainException => e
      showError 'users.domain.exception'
    end
  end

  post '/files' do
    usersToProcces = strToArray(params['sortedIdsStr'])
    @files = Watchdog::Global::Watchdog.getFiles(usersToProcces)
    @users = Watchdog::Global::Watchdog.getUsers @userEmail
    erb :files, :layout => :home_layout
  end

  post '/old-own' do
    currentOwner = 'admincloud@cfarco.com' if @domain == 'cfarco.com'
    currentOwner = 'documentation@watchdog.h2itec.com' if @domain == 'watchdog.h2itec.com'
    usersToProcces = strToArray(params['sortedIdsStr'])
    @files = Watchdog::Global::Watchdog.findFilesToRetrieveOwnership(usersToProcces, currentOwner)
    @users = Watchdog::Global::Watchdog.getUsers @userEmail
    erb :myOldOwn, :layout => :home_layout
  end

  post '/child-folders' do
    docaccount = 'admincloud@cfarco.com' if @domain == 'cfarco.com'
    docaccount = 'documentation@watchdog.h2itec.com' if @domain == 'watchdog.h2itec.com'
    usersToProcces = strToArray(params['sortedIdsStr'])
    @files = Watchdog::Global::Watchdog.files_under_common_structure usersToProcces, docaccount
    erb :child_files, :layout => :home_layout
  end

  post '/new-change-permissions', :provides => :json do
    p 'Give Ownership to central account'
    files = JSON.parse(params['files'])
    files_to_change = Files::FilesToChange.group_by_user files

    docaccount = 'admincloud@cfarco.com' if @domain == 'cfarco.com'
    docaccount = 'documentation@watchdog.h2itec.com' if @domain == 'watchdog.h2itec.com'

    Watchdog::Global::Watchdog.changePermissions(files_to_change, docaccount)
    { :msg => "yeah" }.to_json
  end

  post '/changePermissions' do
    p 'Give Ownership to central account'
    filesIds = params['filesIdsStr']

    @changed = Watchdog::Global::Watchdog.changePermissions(Files::FilesToChange.unmarshall(filesIds), params['newOwnerHidden'])
    erb :changed, :layout => :home_layout
  end

  post '/giveOwnershipBack' do
    p 'Give Ownership Back'
    currentOwner = 'admincloud@cfarco.com' if @domain == 'cfarco.com'
    currentOwner = 'documentation@watchdog.h2itec.com' if @domain == 'watchdog.h2itec.com'
    p currentOwner
    filesIds = params['filesIdsStr']

    @changed = Watchdog::Global::Watchdog.giveOwnershipBack(Files::FilesToChange.unmarshall(filesIds), currentOwner)
    erb :changed, :layout => :home_layout
  end

  post '/fixRoot' do
    usersToProcces = strToArray(params['sortedIdsStrForFixRoot'])
    Watchdog::Global::Watchdog.fixRoot(usersToProcces)
    @files = []
    erb :files, :layout => :home_layout
  end

  post '/unshare' do
    p 'Unshare'
    currentOwner = 'admincloud@cfarco.com' if @domain == 'cfarco.com'
    currentOwner = 'documentation@watchdog.h2itec.com' if @domain == 'watchdog.h2itec.com'
    usersToProcces = strToArray(params['sortedIdsStrForUnshare'])
    Watchdog::Global::Watchdog.unshare(usersToProcces, currentOwner)
    @files = []
    erb :files, :layout => :home_layout
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
