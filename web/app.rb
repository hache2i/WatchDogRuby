require 'sinatra/base'
require 'sinatra/contrib'
require 'mongoid'
require 'logger'

$LOAD_PATH.push(File.expand_path(File.join(File.dirname(__FILE__), '../')))

require_relative './lib/notifier'
require_relative '../wddomain/lib/watchdog'
require_relative '../wdconfig/lib/timing_not_specified_exception'
require_relative '../wdconfig/lib/docsowner_not_specified_exception'

require_relative 'base_app'
require_relative 'login'

require_relative 'lib/activation'
require_relative 'lib/google_authentication'

class Web < BaseApp

  use Login

  helpers Sinatra::Activation
  helpers Sinatra::GoogleAuthentication

    _watchdog = WDDomain::Watchdog.new
    _watchdog.load

  set :public_folder, './web/public'
  set :static, true

  before do
    require_authentication
    @domain = session[:domain]
    @userEmail = session[:user_attributes][:email]
    require_activation
  end

  get '/index.html' do
    erb :index
  end

  get '/' do
    @message = Notifier.message_for params['alert_signal']
    erb :index
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
    erb :index
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
      @userNames = _watchdog.getUsers(email)
      erb :users, :layout => :home_layout
    rescue
      showError 'not.admin'
    end
  end

  post '/files' do
    @users = strToArray(params['sortedIdsStr'])

    @files = _watchdog.getFiles(@users)
    erb :files, :layout => :home_layout
  end

  post '/changePermissions' do
    filesIds = params['filesIdsStr']

    @changed = _watchdog.changePermissions(Files::FilesToChange.unmarshall(filesIds), params['newOwnerHidden'])
    erb :changed, :layout => :home_layout
  end

  def loggedUserMail
    api_client.authorization = user_credentials
    oauth2 = api_client.discovered_api('oauth2', 'v2')
    result = api_client.execute!(:api_method => oauth2.userinfo.get)
    user_info = nil
    if result.status == 200
      user_info = result.data
      user_info.email
    else
      nil
    end
  end

  def showError(messageKey)
      @message = Notifier.message_for messageKey
      erb :index
  end

  def strToArray(usersStr)
    return [] if usersStr.nil?
    usersStr.split(',')
  end

end
