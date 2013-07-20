require 'sinatra/base'

$LOAD_PATH.push(File.expand_path(File.join(File.dirname(__FILE__), '../')))

require_relative './lib/notifier'
require_relative '../files/lib/files_domain'

require 'gappsprovisioning/provisioningapi'
include GAppsProvisioning

class Web < Sinatra::Base
  set :public_folder, './web/public'
  set :static, true

  _filesDomain = Files::FilesDomain.new

  not_found do
    erb :'404', :layout => :home_layout
  end

  get '/index.html' do
    erb :index , :layout => :home_layout
  end

  get '/' do
    @message = Notifier.message_for params['alert_signal']
    erb :index , :layout => :home_layout
  end

  post '/users' do
    begin
      email = params['email']
      domain = extractDomainFromEmail(email)
      password = params['password']
      myapps = ProvisioningApi.new(email, password)

      list = myapps.retrieve_all_users
      @userNames = list.map{|user| user.username + '@' + domain}
      erb :users, :layout => :home_layout
    rescue
      showError 'not.admin'
    end
  end

  post '/files' do
    users = strToArray(params['sortedIdsStr'])

    @files = _filesDomain.getFiles(users)
    erb :files, :layout => :home_layout
  end

  post '/changePermissions' do
    filesIds = params['filesIdsStr']

    @files = _filesDomain.changePermissions(strToArray(filesIds), params['newOwnerHidden'])
    erb :files, :layout => :home_layout
  end

  def extractDomainFromEmail(email)
    email.scan(/(.+)@(.+)/)[0][1]
  end

  def showError(messageKey)
      @message = Notifier.message_for messageKey
      erb :index , :layout => :home_layout
  end

  def strToArray(usersStr)
    return [] if usersStr.nil?
    usersStr.split(',')
  end

end
