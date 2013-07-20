class Notifier

	Messages = {
		'not.admin' => 'You are not a domain administrator.'
	}

	def self.message_for(alert_signal)
	    message = Messages[alert_signal]
		message = '' if message.nil?
		message
	end
end