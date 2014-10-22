require 'bundler/setup'
require 'sinatra/base'
require 'omniauth'
require 'google/omniauth'
require 'google/api_client/client_secrets'

# require 'gapps_openid'
# require 'rack/openid'

require_relative 'base_app'
require_relative 'lib/google_authentication'
require_relative 'lib/notifier'

p "nainonai"
CLIENT_SECRETS = Google::APIClient::ClientSecrets.load
p "lelele"
class Login < BaseApp

  use OmniAuth::Builder do
    provider OmniAuth::Strategies::Google,
      CLIENT_SECRETS.client_id,
      CLIENT_SECRETS.client_secret,
      :scope => [
        'https://www.googleapis.com/auth/userinfo.profile',
        'https://www.googleapis.com/auth/userinfo.email',
        'https://www.googleapis.com/auth/admin.directory.user',
        'https://www.googleapis.com/auth/drive'
      ],
      :skip_info => false
  end

  # use Rack::OpenID

  # def client
  #   p "client method"
  #   c = (Thread.current[:client] ||= 
  #       Google::APIClient.new(:application_name => 'Watchdog',
  #                             :application_version => '1.0.0'))
  #   # It's really important to clear these out,
  #   # since we reuse client objects across requests
  #   # for caching and performance reasons.
  #   c.authorization.clear_credentials!
  #   return c
  # end

  # def plus_api; settings.plus; end

  # configure do
  #   p "configure"
  #   # Since we're saving the API definition to the settings, we're only
  #   # retrieving it once (on server start) and saving it between requests.
  #   # If this is still an issue, you could serialize the object and load it on
  #   # subsequent runs.
  #   plus = Google::APIClient.new.discovered_api('plus', 'v1')
  #   set :plus, plus
  # end
  
  # Support both GET and POST for callbacks.
  %w(get post).each do |method|
    p "is calling " + method
    send(method, "/auth/:provider/callback") do
      p "kind of callback"
      p env['omniauth.auth']['credentials']['decoded_id_token']['email']
      # Thread.current[:client] = env['omniauth.auth']['extra']['client']
      
      # Keep track of the tokens. Use a real database in production.
      session['uid'] = env['omniauth.auth']['uid']
      session['credentials'] = env['omniauth.auth']['credentials']

      redirect '/domain'      
    end
  end

  get '/auth/failure' do
    unless production?
      # Something went wrong. Dump the environment to help debug.
      # DO NOT DO THIS IN PRODUCTION.
      content_type 'application/json'
      MultiJson.encode(request.env)
    else
      content_type 'text/plain'
      "Something went wrong."
    end
  end

  get '/login' do
    p "login route"
    redirect '/auth/google'
    # if params["openid_identifier"].nil? || params["openid_identifier"].empty?
    #   # No identifier, just render login form
    #   erb :login
    # else
    #   session[:domain] = params["openid_identifier"]
    #   # Have provider identifier, tell rack-openid to start OpenID process
    #   headers 'WWW-Authenticate' => Rack::OpenID.build_header(
    #     :identifier => params["openid_identifier"],
    #     :required => ["http://axschema.org/contact/email", 
    #                   "http://axschema.org/namePerson/first",
    #                   "http://axschema.org/namePerson/last"],
    #     :return_to => url_for('/openid/complete'),
    #     :method => 'post'
    #     )
    #   halt 401, 'Authentication required.'
    # end
  end


  # helpers Sinatra::GoogleAuthentication
  
  # before do
  #   @domain = session[:domain]
  #   @openid = session[:openid]
  #   @user_attrs = session[:user_attributes]
  # end

  # # Clear the session
  # get '/logout' do
  #   session.clear
  #   redirect '/login'
  # end

  # # Handle login form & navigation links from Google Apps
  # get '/login' do
  #   if params["openid_identifier"].nil? || params["openid_identifier"].empty?
  #     # No identifier, just render login form
  #     erb :login
  #   else
  #     session[:domain] = params["openid_identifier"]
  #     # Have provider identifier, tell rack-openid to start OpenID process
  #     headers 'WWW-Authenticate' => Rack::OpenID.build_header(
  #       :identifier => params["openid_identifier"],
  #       :required => ["http://axschema.org/contact/email", 
  #                     "http://axschema.org/namePerson/first",
  #                     "http://axschema.org/namePerson/last"],
  #       :return_to => url_for('/openid/complete'),
  #       :method => 'post'
  #       )
  #     halt 401, 'Authentication required.'
  #   end
  # end

  # # Handle the response from the OpenID provider
  # post '/openid/complete' do
  #   resp = request.env["rack.openid.response"]
  #   if resp.status == :success
  #     session[:openid] = resp.display_identifier
  #     ax = OpenID::AX::FetchResponse.from_success_response(resp)
  #     session[:user_attributes] = {
  #       :email => ax.get_single("http://axschema.org/contact/email"),
  #       :first_name => ax.get_single("http://axschema.org/namePerson/first"),
  #       :last_name => ax.get_single("http://axschema.org/namePerson/last")     
  #     }
  #     redirect '/'
  #   else
  #     session[:domain] = nil
  #     "Error: #{resp.status}"
  #   end
  # end

  get '/requestActivation' do
    erb :request_activation, :layout => :home_layout
  end

  get '/notDomainAdmin' do
    @message = Notifier.message_for 'not.admin'
    erb :'401', :layout => :home_layout
  end

  get '/support' do 
    erb :'404', :layout => :home_layout
  end

  get '/manifest.xml' do
    content_type 'text/xml'
    erb :manifest, :layout => false
  end

  not_found do
    erb :'404', :layout => :home_layout
  end

end

