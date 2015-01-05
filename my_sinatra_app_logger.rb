module MySinatraAppLogger
  extend ActiveSupport::Concern

  class << self
    def logger_instance
      @logger_instance ||= ::Logger.new(log_file).tap do |logger|
        ::Logger.class_eval { alias :write :'<<' }
        logger.level = ::Logger::INFO
      end
    end

    def log_file
      @log_file ||= File.new("#{BaseApp.settings.root}/log/#{BaseApp.settings.environment}.log", 'a+').tap do |log_file|
        log_file.sync = true
      end
    end
  end

  included do
    configure do
      enable :logging
      use Rack::CommonLogger, MySinatraAppLogger.logger_instance
    end

    before { env["rack.errors"] = MySinatraAppLogger.log_file }
  end

  def logger
    MySinatraAppLogger.logger_instance
  end
end