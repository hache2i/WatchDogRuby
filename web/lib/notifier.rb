class Notifier

	Messages = {
		'not.admin' => 'You are not a domain administrator.',
		'config.saved' => 'Your scheduled execution config has been saved.',
		'scheduled.execution.config.timing.required' => 'You have to specify the timing.',
		'scheduled.execution.config.docsowner.required' => 'You have to specify the docs owner.'
	}

	def self.message_for(alert_signal)
	    message = Messages[alert_signal]
		message = '' if message.nil?
		message
	end
end