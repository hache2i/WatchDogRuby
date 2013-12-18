require 'rufus-scheduler'
require_relative 'job_view'

module WDDomain
	class Scheduler

		def initialize(aWatchdog, aExecutionLog)
			@scheduler = Rufus::Scheduler.new
			@jobs = {}
			@watchdog = aWatchdog
			@executionLog = aExecutionLog
		end

		def getJobs
			@jobs.keys.map{|jobDomain| JobView.new(jobDomain, @jobs[jobDomain])}
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
				@executionLog.add('starting job execution', config.domain)
				@watchdog.reassingOwnership(config.getAdmin, config.getDocsOwner)
				@executionLog.add('job execution finished!!', config.domain)
			end
			@jobs.merge!({config.domain => job})
			config.schedule
		end

		def scheduleOnce(domain, admin, docsOwner)
			job = @scheduler.schedule_in '1s' do
				@executionLog.add('starting job execution', domain)
				@watchdog.reassingOwnership(admin, docsOwner)
				@executionLog.add('job execution finished!!', domain)
			end
		end

		def unschedule(domain)
			return if @jobs.nil? || @jobs.empty?
			job = @jobs[domain]
			if !job.nil?
				job.unschedule
				@jobs.delete domain
				@executionLog.add('unscheduled job execution', domain)
			end
		end

		private

		def convertToSecs(minutes)
			0 if minutes.nil?
			minutes.to_i * 60
		end

	end
end