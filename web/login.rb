require 'sinatra/base'
require 'gapps_openid'
require 'rack/openid'

require_relative 'base_app'
require_relative 'lib/google_authentication'
require_relative 'lib/notifier'

class Login < BaseApp

  use Rack::OpenID

  helpers Sinatra::GoogleAuthentication
  
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

  get '/home' do
      erb :home
  end

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