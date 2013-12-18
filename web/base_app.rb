require 'sinatra/base'

require_relative '../wdadmin/lib/domains'
require_relative '../wddomain/lib/watchdog_domain'

class BaseApp < Sinatra::Base

  use Rack::Session::Cookie, secret: 'change_me'

  configure do
    set :run, false
    Mongoid.load!("config/mongoid.yml")
    Watchdog::Global::Watchdog.init
  end

end