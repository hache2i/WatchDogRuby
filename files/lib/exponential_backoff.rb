class ExponentialBackoff
	def self.exp_backoff(upto)
		result = [ ]
		(1..upto).each do |iter|
			result << ((2.0**iter) + (rand(1001.0) / 1000.0))
		end
		return result
	end
end