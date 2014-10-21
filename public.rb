require 'sinatra/base'

class Public < BaseApp

  use Login

  before do
  	@domain = session[:domain]
  end

  get '/home' do
      erb :home
  end

  get '/index.html' do
    erb :home
  end

  get '/' do
  	redirect '/domain' if !@domain.nil?
    erb :home
  end

end