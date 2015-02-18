require_relative 'my_sinatra_app_logger'

module WDLogger
  def self.info msg
    MySinatraAppLogger.logger.info "INFO: #{ traced_msg msg }"
  end

  def self.error msg
    MySinatraAppLogger.logger.error "ERROR: #{ traced_msg msg }"
  end

  def self.debug msg
    MySinatraAppLogger.logger.debug "DEBUG: #{ traced_msg msg }"
  end

  def self.traced_msg msg
    "#{ trace_time } - #{ msg }"
  end

  def self.trace_time
    DateTime.now.strftime("%d/%m/%Y %H:%M:%S")
  end
end