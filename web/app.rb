require 'sinatra/base'
require 'sinatra/contrib'
require 'mongoid'
require 'logger'

$LOAD_PATH.push(File.expand_path(File.join(File.dirname(__FILE__), '../')))

require_relative './lib/notifier'
require_relative '../wddomain/lib/watchdog'
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

    _watchdog = WDDomain::Watchdog.new(Watchdog::Global::Domains)
    _watchdog.load

  set :public_folder, './web/public'
  set :static, true

  before do
    require_authentication
    @domain = get_domain
    @userEmail = get_user_email
    require_activation
    redirect '/notDomainAdmin' if !_watchdog.isAdmin @userEmail
  end

  get '/index.html' do
    erb :index, :layout => :home_layout
  end

  get '/' do
    @message = Notifier.message_for params['alert_signal']
    erb :index, :layout => :home_layout
  end

  get '/config' do
    executionConfig = _watchdog.getScheduledExecutionConfig(@domain)
    @timing = executionConfig.getTiming
    @newOwner = executionConfig.getDocsOwner
    @scheduled = executionConfig.scheduled?
    erb :config, :layout => :home_layout
  end

  post '/config' do
    begin
      _watchdog.configScheduledExecution(@domain, @userEmail, params['newOwner'], params['timing'])
      @message = Notifier.message_for 'config.saved'
    rescue TimingNotSpecifiedException => e
      showError 'scheduled.execution.config.timing.required'
    rescue DocsownerNotSpecifiedException => e
      showError 'scheduled.execution.config.docsowner.required'
    end
    erb :index, :layout => :home_layout
  end

  post '/scheduleOnce' do
    _watchdog.scheduleOnce(@domain, @userEmail, params['newOwner'])
    erb :index, :layout => :home_layout
  end

  get '/unschedule' do
    executionConfig = _watchdog.unschedule(@domain)
    @timing = executionConfig.getTiming
    @newOwner = executionConfig.getDocsOwner
    @scheduled = executionConfig.scheduled?
    erb :config, :layout => :home_layout
  end

  get '/users' do
    begin
      email = @userEmail
      @users = _watchdog.getUsers(email)
      erb :users, :layout => :home_layout
    rescue UsersDomainException => e
      showError 'users.domain.exception'
    end
  end

  post '/files' do
    usersToProcces = strToArray(params['sortedIdsStr'])
    @files = _watchdog.getFiles(usersToProcces)
    @users = _watchdog.getUsers @userEmail
    erb :files, :layout => :home_layout
  end

  post '/changePermissions' do
    filesIds = params['filesIdsStr']

    @changed = _watchdog.changePermissions(Files::FilesToChange.unmarshall(filesIds), params['newOwnerHidden'])
    erb :changed, :layout => :home_layout
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
