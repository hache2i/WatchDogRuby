class JobView
	def initialize(aDomain, aJob)
		@domain = aDomain
		@job = aJob
	end
	def domain
		@domain
	end
	def next_run
		begin
			@job.next_time
		rescue
			''
		end
	end
	def frequency
		begin
			(@job.frequency / 60).ceil.to_s + ' min'
		rescue
			''
		end
	end
end