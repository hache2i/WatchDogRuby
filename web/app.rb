require 'sinatra'
require 'google/api_client'
require 'logger'

$LOAD_PATH.push(File.expand_path(File.join(File.dirname(__FILE__), '../')))

require_relative './lib/notifier'
require_relative '../files/lib/files_domain'
require_relative '../files/lib/files_to_change'
require_relative '../users/lib/users_domain'

require 'gapps_openid'
require 'rack/openid'
require_relative './lib/google_util'

use Rack::Session::Cookie
use Rack::OpenID

CONSUMER_KEY = '111623891942-an2kf1pr99oaoth8s8ncusb6so2i8nn2.apps.googleusercontent.com'
CONSUMER_SECRET = 'WxIJmSkIFjq2LHzedY77bIDu'

# class Web < Sinatra::Base
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

  _filesDomain = Files::FilesDomain.new

  enable :sessions

  before do
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
    if params["openid_identifier"].nil?
      # No identifier, just render login form
      erb :login
    else
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
      "Error: #{resp.status}"
    end
  end

  not_found do
    erb :'404', :layout => :home_layout
  end

  get '/index.html' do
    require_authentication
    erb :index
  end

  get '/' do
    require_authentication

    @message = Notifier.message_for params['alert_signal']
    erb :index
  end

  get '/users' do
    require_authentication

    begin
      email = @user_attrs[:email]
      usersDomain = Users::UsersDomain.new
      @userNames = usersDomain.getUsers(email)
      erb :users, :layout => :home_layout
    rescue
      showError 'not.admin'
    end
  end

  post '/files' do
    require_authentication

    @users = strToArray(params['sortedIdsStr'])

    @files = _filesDomain.getFiles(@users)
    erb :files, :layout => :home_layout
  end

  post '/changePermissions' do
    require_authentication

    filesIds = params['filesIdsStr']

    @files = _filesDomain.changePermissions(Files::FilesToChange.unmarshall(filesIds), params['newOwnerHidden'])
    erb :files, :layout => :home_layout
  end

  post '/demo' do
    require_authentication
      email = params['email']
      puts 'email: ' + email
      newOwner = params['newOwner']
      puts 'newOwner' + newOwner
      usersDomain = Users::UsersDomain.new
      userNames = usersDomain.getUsers(email)
      # files = _filesDomain.getFiles(userNames)
      # _filesDomain.changePermissions(Files::FilesToChange.unmarshall(files.to_s), newOwner)
      'ok'
  end

  get '/demo' do
    puts params['email']
    puts params['domain']
  end

  get '/support' do 
    erb :'404', :layout => :home_layout
  end

  get '/manifest.xml' do
    content_type 'text/xml'
    erb :manifest, :layout => false
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
