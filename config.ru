require File.join(File.dirname(__FILE__), 'app.rb')
require File.join(File.dirname(__FILE__), 'admin.rb')
require File.join(File.dirname(__FILE__), 'public.rb')

map "/" do
   run Public
end

map "/domain" do
   run Web
end

map "/admin" do
	run Admin
end
