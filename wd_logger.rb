require_relative 'my_sinatra_app_logger'
require_relative 'wddomain/lib/global_execution_log'

module WDLogger
  def self.info msg
    Watchdog::Global::Logs::Execution.add msg
    MySinatraAppLogger.logger.info "INFO: #{ traced_msg msg }"
  end

  def self.error msg
    Watchdog::Global::Logs::Execution.add msg
    MySinatraAppLogger.logger.error "ERROR: #{ traced_msg msg }"
  end

  def self.debug msg
    Watchdog::Global::Logs::Execution.add msg
    MySinatraAppLogger.logger.debug "DEBUG: #{ traced_msg msg }"
  end

  def self.traced_msg msg
    "#{ trace_time } - #{ msg }"
  end

  def self.trace_time
    DateTime.now.strftime("%d/%m/%Y %H:%M:%S")
  end
end