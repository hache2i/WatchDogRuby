require 'rufus-scheduler'

module WDDomain
	class Scheduler

		def initialize(aWatchdog)
			@scheduler = Rufus::Scheduler.new
			@jobs = {}
			@watchdog = aWatchdog
		end

		def scheduleAll(configs)
			configs.each do |config|
				schedule(config) if config.scheduled?
			end
		end

		def schedule(config)
			unschedule(config.domain)
			schedTime = convertToSecs(config.getTiming).to_s + 's'
			job = @scheduler.schedule_every schedTime, :mutex => config.domain do
				puts 'starting job execution for ' + config.domain
				@watchdog.reassingOwnership(config.getAdmin, config.getDocsOwner)
				puts 'job execution for ' + config.domain + ' finished!!'
			end
			@jobs.merge!({config.domain => job})
			config.schedule
		end

		def scheduleOnce(domain, admin, docsOwner)
			job = @scheduler.schedule_in '1s' do
				puts 'starting job execution for ' + domain
				@watchdog.reassingOwnership(admin, docsOwner)
				puts 'job execution for ' + domain + ' finished!!'
			end
		end

		def unschedule(domain)
			return if @jobs.nil? || @jobs.empty?
			job = @jobs[domain]
			job.unschedule if !job.nil?
		end

		private

		def convertToSecs(minutes)
			0 if minutes.nil?
			minutes.to_i * 60
		end

	end
end