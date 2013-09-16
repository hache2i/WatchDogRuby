require 'sinatra/base'

require_relative '../wdadmin/lib/domains'

class BaseApp < Sinatra::Base

  configure do
    set :run, false
    Mongoid.load!("config/mongoid.yml")
  end

end