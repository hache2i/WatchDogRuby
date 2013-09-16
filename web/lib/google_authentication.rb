module Sinatra
	module GoogleAuthentication
	    def require_authentication    
	      redirect '/login' unless authenticated?
	    end 
	    
	    def authenticated?
	      !session[:openid].nil?
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