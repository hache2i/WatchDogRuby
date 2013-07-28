require 'sinatra'
require 'google/api_client'
require 'logger'

$LOAD_PATH.push(File.expand_path(File.join(File.dirname(__FILE__), '../')))

require_relative './lib/notifier'
require_relative '../files/lib/files_domain'
require_relative '../files/lib/files_to_change'
require_relative '../users/lib/users_domain'

class Web < Sinatra::Base
  set :public_folder, './web/public'
  set :static, true

  _filesDomain = Files::FilesDomain.new

  enable :sessions

  def logger; settings.logger end

  def api_client; settings.api_client; end

  def calendar_api; settings.calendar; end

  def user_credentials
    # Build a per-request oauth credential based on token stored in session
    # which allows us to use a shared API client.
    @authorization ||= (
      auth = api_client.authorization.dup
      auth.redirect_uri = to('/oauth2callback')
      auth.update_token!(session)
      auth
    )
  end

  configure do
    log_file = File.open('watchdog.log', 'a+')
    log_file.sync = true
    logger = Logger.new(log_file)
    logger.level = Logger::DEBUG
    
    client = Google::APIClient.new
    client.authorization.client_id = '111623891942-an2kf1pr99oaoth8s8ncusb6so2i8nn2.apps.googleusercontent.com'
    client.authorization.client_secret = 'WxIJmSkIFjq2LHzedY77bIDu'
    client.authorization.scope = ['https://www.googleapis.com/auth/userinfo.email', 'https://www.googleapis.com/auth/drive', 'https://www.googleapis.com/auth/admin.directory.user']

    set :logger, logger
    set :api_client, client
  end

  before do
    # Ensure user has authorized the app
    unless user_credentials.access_token || request.path_info =~ /^\/oauth2/
      redirect to('/oauth2authorize')
    end
  end

  after do
    # Serialize the access/refresh token to the session
    session[:access_token] = user_credentials.access_token
    session[:refresh_token] = user_credentials.refresh_token
    session[:expires_in] = user_credentials.expires_in
    session[:issued_at] = user_credentials.issued_at
  end

  get '/oauth2authorize' do
    # Request authorization
    redirect user_credentials.authorization_uri.to_s, 303
  end

  get '/oauth2callback' do
    # Exchange token
    user_credentials.code = params[:code] if params[:code]
    user_credentials.fetch_access_token!
    redirect to('/users')
  end

  not_found do
    erb :'404', :layout => :home_layout
  end

  get '/index.html' do
    erb :index
  end

  get '/' do
    @message = Notifier.message_for params['alert_signal']
    erb :index
  end

  get '/users' do
    begin
      email = loggedUserMail
      usersDomain = Users::UsersDomain.new
      @userNames = usersDomain.getUsers(email)
      erb :users, :layout => :home_layout
    rescue
      showError 'not.admin'
    end
  end

  post '/files' do
    @users = strToArray(params['sortedIdsStr'])

    @files = _filesDomain.getFiles(@users)
    erb :files, :layout => :home_layout
  end

  post '/changePermissions' do
    filesIds = params['filesIdsStr']

    @files = _filesDomain.changePermissions(Files::FilesToChange.unmarshall(filesIds), params['newOwnerHidden'])
    erb :files, :layout => :home_layout
  end

  get '/support' do 
    erb :'404', :layout => :home_layout
  end

  get '/manifest' do
    erb :manifest
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
