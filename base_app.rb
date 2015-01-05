require 'sinatra/base'

require_relative './wdadmin/lib/domains'
require_relative './wddomain/lib/watchdog_domain'
require_relative './my_sinatra_app_logger'

class BaseApp < Sinatra::Base

  use Rack::Session::Cookie, secret: 'change_me'

  include MySinatraAppLogger

  configure do
    set :run, false
    Mongoid.load!("config/mongoid.yml")
    Watchdog::Global::Watchdog.init
  end

end

