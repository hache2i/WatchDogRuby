require_relative 'execution_configuration'
require_relative 'execution_configurations'

module WDConfig
	class ConfigDomain

		def initialize
			@configs = ExecutionConfigurations.new
		end

		def all
			@configs.all
		end

		def getScheduledExecution(domain)
			config = @configs.get(domain)
			return ExecutionConfiguration.new(domain: '', admin: '', docsOwner: '', timing: '') if config.nil?
			config
		end

		def configScheduledExecution(domain, admin, docsOwner, timing)
			raise DocsownerNotSpecifiedException if docsOwner.nil? || docsOwner.empty?
			raise TimingNotSpecifiedException if timing.nil? || timing.empty?

			config = ExecutionConfiguration.new(domain: domain, admin: admin, docsOwner: docsOwner, timing: timing, scheduled: true)
			@configs.store(config)
		end

		def unschedule(domain)
			config = @configs.get(domain)
			config.unschedule
		end

		def hasScheduled?(domain)
			config = @configs.get(domain)
			!config.nil? && config.scheduled?
		end
	end
end