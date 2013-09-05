require File.join(File.dirname(__FILE__), 'web/app.rb')

map "/" do
   run Web
end

