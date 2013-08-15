require_relative 'execution_configuration'

module WDConfig
	class ExecutionConfigurations

		def initialize
		end

		def empty?
			ExecutionConfiguration.all.empty?
		end

		def all
			ExecutionConfiguration.all
		end

		def store(config)
			persist(config)
		end

		def get(domain)
			ExecutionConfiguration.where(domain: domain).first
		end

		private 

		def persist(config)
			domainConfig = ExecutionConfiguration.find_or_create_by(domain: config.domain)
			domainConfig.update_attributes({
				:admin => config.getAdmin,
				:docsOwner => config.getDocsOwner,
				:timing => config.getTiming,
				:scheduled => config.scheduled?
				})
			domainConfig
		end
	end
end