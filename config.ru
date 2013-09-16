require File.join(File.dirname(__FILE__), 'web/app.rb')
require File.join(File.dirname(__FILE__), 'web/admin.rb')

map "/" do
   run Web
end

map "/admin" do
	run Admin
end
