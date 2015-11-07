require 'sinatra/base'

require_relative './wdadmin/lib/domains'
require_relative './wddomain/lib/watchdog_domain'
require_relative './my_sinatra_app_logger'

class BaseApp < Sinatra::Base

  use Rack::Session::Cookie, secret: 'change_me'

  include MySinatraAppLogger

  configure do
    set :run, false
    p "CONFIGUREEEEEE"
    Mongoid.load!("config/mongoid.yml")
    Watchdog::Global::Watchdog.init
  end

end

class String
  def to_bool
    return true if self == true || self =~ (/^(true|t|yes|y|1)$/i)
    return false if self == false || self.blank? || self =~ (/^(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end
end

class Fixnum
  def to_bool
    return true if self == 1
    return false if self == 0
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end
end

class TrueClass
  def to_i; 1; end
  def to_bool; self; end
end

class FalseClass
  def to_i; 0; end
  def to_bool; self; end
end

class NilClass
  def to_bool; false; end
end
