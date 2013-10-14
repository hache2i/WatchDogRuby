module Sinatra
	module GoogleAuthentication
	    def require_authentication    
	      redirect '/login' unless authenticated?
	    end 
	    
	    def authenticated?
	      !session[:openid].nil?
	    end
	    
	    def get_domain
	    	session[:domain]
	    end

	    def get_user_email
	    	session[:user_attributes][:email]
	    end

	    def get_openid
	    	session[:openid]
	    end
	    
	    def url_for(path)
	      url = request.scheme + "://"
	      url << request.host

	      scheme, port = request.scheme, request.port
	      if scheme == "https" && port != 443 ||
	          scheme == "http" && port != 80
	        url << ":#{port}"
	      end
	      url << path
	      url
	    end
	end
end