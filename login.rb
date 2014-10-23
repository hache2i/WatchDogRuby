require 'bundler/setup'
require 'sinatra/base'
require 'omniauth'
require 'google/omniauth'
require 'google/api_client/client_secrets'

require_relative 'base_app'
require_relative 'lib/google_authentication'
require_relative 'lib/notifier'

CLIENT_SECRETS = Google::APIClient::ClientSecrets.load

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

  # Support both GET and POST for callbacks.
  %w(get post).each do |method|
    p "is calling " + method
    send(method, "/auth/:provider/callback") do
      p "kind of callback"
      p env['omniauth.auth']['credentials']['decoded_id_token']['email']

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
    redirect '/auth/google'
  end


  # # Clear the session
  # get '/logout' do
  #   session.clear
  #   redirect '/login'
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

