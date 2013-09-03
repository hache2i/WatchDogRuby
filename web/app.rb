require 'sinatra'
require 'google/api_client'
require 'mongoid'
require 'logger'

$LOAD_PATH.push(File.expand_path(File.join(File.dirname(__FILE__), '../')))

require_relative './lib/notifier'
require_relative '../wddomain/lib/watchdog'
require_relative '../wdconfig/lib/timing_not_specified_exception'
require_relative '../wdconfig/lib/docsowner_not_specified_exception'

require 'rufus-scheduler'
require 'gapps_openid'
require 'rack/openid'
require_relative './lib/google_util'

use Rack::Session::Cookie
use Rack::OpenID

CONSUMER_KEY = '111623891942-an2kf1pr99oaoth8s8ncusb6so2i8nn2.apps.googleusercontent.com'
CONSUMER_SECRET = 'WxIJmSkIFjq2LHzedY77bIDu'

# class Web < Sinatra::Base
  configure do
    Mongoid.load!("config/mongoid.yml")
  end

  helpers do
    def require_authentication    
      redirect '/login' unless authenticated?
    end 
    
    def authenticated?
      !session[:openid].nil?
    end
    
    def url_for(path)
      url = request.scheme + "://"
      url << request.host

      scheme, port = request.scheme, request.port
      if scheme == "https" && port != 443 ||
          scheme == "http" && port != 80
        url << ":#{port}"
      end
      url << path
      url
    end
  end

  set :public_folder, './web/public'
  set :static, true

  _watchdog = WDDomain::Watchdog.new
  _watchdog.load

  get '/index.html' do
    require_authentication
    erb :index
  end

  get '/' do
    require_authentication

    @message = Notifier.message_for params['alert_signal']
    erb :index
  end

  get '/config' do
    require_authentication

    executionConfig = _watchdog.getScheduledExecutionConfig(@domain)
    @timing = executionConfig.getTiming
    @newOwner = executionConfig.getDocsOwner
    @scheduled = executionConfig.scheduled?
    erb :config, :layout => :home_layout
  end

  post '/config' do
    require_authentication

    begin
      _watchdog.configScheduledExecution(@domain, @user_attrs[:email], params['newOwner'], params['timing'])
      @message = Notifier.message_for 'config.saved'
    rescue TimingNotSpecifiedException => e
      showError 'scheduled.execution.config.timing.required'
    rescue DocsownerNotSpecifiedException => e
      showError 'scheduled.execution.config.docsowner.required'
    end
    erb :index
  end

  get '/unschedule' do
    require_authentication

    executionConfig = _watchdog.unschedule(@domain)
    @timing = executionConfig.getTiming
    @newOwner = executionConfig.getDocsOwner
    @scheduled = executionConfig.scheduled?
    erb :config, :layout => :home_layout
  end

  get '/users' do
    require_authentication

    begin
      email = @user_attrs[:email]
      @userNames = _watchdog.getUsers(email)
      erb :users, :layout => :home_layout
    rescue
      showError 'not.admin'
    end
  end

  post '/files' do
    require_authentication

    @users = strToArray(params['sortedIdsStr'])

    @files = _watchdog.getFiles(@users)
    erb :files, :layout => :home_layout
  end

  post '/changePermissions' do
    require_authentication

    filesIds = params['filesIdsStr']

    @changed = _watchdog.changePermissions(Files::FilesToChange.unmarshall(filesIds), params['newOwnerHidden'])
    puts @changed
    erb :changed, :layout => :home_layout
  end

  get '/support' do 
    erb :'404', :layout => :home_layout
  end

  get '/manifest.xml' do
    content_type 'text/xml'
    erb :manifest, :layout => false
  end

  before do
    @domain = session[:domain]
    @openid = session[:openid]
    @user_attrs = session[:user_attributes]
  end

  # Clear the session
  get '/logout' do
    session.clear
    redirect '/login'
  end

  # Handle login form & navigation links from Google Apps
  get '/login' do
    if params["openid_identifier"].nil? || params["openid_identifier"].empty?
      # No identifier, just render login form
      erb :login
    else
      session[:domain] = params["openid_identifier"]
      # Have provider identifier, tell rack-openid to start OpenID process
      headers 'WWW-Authenticate' => Rack::OpenID.build_header(
        :identifier => params["openid_identifier"],
        :required => ["http://axschema.org/contact/email", 
                      "http://axschema.org/namePerson/first",
                      "http://axschema.org/namePerson/last"],
        :return_to => url_for('/openid/complete'),
        :method => 'post'
        )
      halt 401, 'Authentication required.'
    end
  end

  # Handle the response from the OpenID provider
  post '/openid/complete' do
    resp = request.env["rack.openid.response"]
    if resp.status == :success
      session[:openid] = resp.display_identifier
      ax = OpenID::AX::FetchResponse.from_success_response(resp)
      session[:user_attributes] = {
        :email => ax.get_single("http://axschema.org/contact/email"),
        :first_name => ax.get_single("http://axschema.org/namePerson/first"),
        :last_name => ax.get_single("http://axschema.org/namePerson/last")     
      }
      redirect '/'
    else
      session[:domain] = nil
      "Error: #{resp.status}"
    end
  end

  not_found do
    erb :'404', :layout => :home_layout
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

# end
