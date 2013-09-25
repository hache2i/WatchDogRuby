module AdminHelper
    def activateDomain(domain, licenses = nil)
		# basic_auth 'foo', 'bar'
		visit "/admin/activateDomain"
		fill_in 'domain', :with => domain
		fill_in 'licenses', :with => licenses if !licenses.nil?
		selector('button#add-domain').click
    end
	def basic_auth(name, password)
	  encoded_login = ["#{name}:#{password}"].pack("m*")
	  page.driver.header 'Authorization', "Basic #{encoded_login}"
	end
end