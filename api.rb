require 'sinatra/base'
require 'sinatra/contrib'
require 'mongoid'
require 'logger'
require 'json'

$LOAD_PATH.push(File.expand_path(File.join(File.dirname(__FILE__), './')))

require_relative './wddomain/lib/threads'
require_relative './wddomain/lib/watchdog_domain'
require_relative './wddomain/lib/domain_data'
require_relative './files/lib/changed'
require_relative './actions/get_pending_proposals'
require_relative './actions/get_files_count'
require_relative './actions/get_users_with_files'
require_relative './actions/get_files'
require_relative './actions/get_common_folders'
require_relative './actions/change_all_pending_files'
require_relative './actions/change_pending_file'

require_relative 'base_app'

require_relative 'lib/activation'
require_relative 'lib/google_authentication'

class Api < BaseApp

  helpers Sinatra::Activation
  helpers Sinatra::GoogleAuthentication

  before do
    @domain = get_domain
    @userEmail = get_user_email
  end

  get '/users', provides: :json do
    users = Watchdog::Global::Watchdog.getUsers @userEmail, @domain
    users_data = users.map do |user|
      { email: user.email, name: user.name }
    end
    users_data.to_json
  end

  get '/common-folders', :provides => :json do
    docaccount = Watchdog::Global::Watchdog.getDocsAdmin(@domain)
    common_folders =  Wd::Actions::GetCommonFolders.do docaccount
    common_folders.to_json
  end

  get '/thread-status', :provides => :json do
    threads_statuses = Watchdog::Global::Threads.get.map do |thr|
      "#{thr[:name]} - #{thr.alive?} - #{thr.status}"
    end
    threads_statuses.to_json
  end

  get '/files/count', :provides => :json do
    WDLogger.debug "Getting Files Count"

    p params["filter"]
    domain_filter = to_domain_filter params["filter"]
    files_count = Wd::Actions::GetFilesCount.do @domain, domain_filter

    files_count.to_json
  end

  post '/files/list', :provides => :json do
    WDLogger.debug "Getting Files"

    from = params[:from].to_i

    domain_filter = to_domain_filter params["filter"]
    access_data = { userEmail: @userEmail, domain: @domain }
    files = Wd::Actions::GetFiles.do from, domain_filter, access_data

    files.to_json
  end

  get '/files/users', :provides => :json do
    WDLogger.debug "Getting Users with Pending Files"

    domain_filter = to_domain_filter params["filter"]
    access_data = { userEmail: @userEmail, domain: @domain }
    users = Wd::Actions::GetUsersWithFiles.do access_data, domain_filter

    users.to_json
  end

  post '/pending/change/all', :provides => :json do
    WDLogger.debug "Changing permission for all pending files"

    filter = params[:filter]
    filter = nil if filter.eql? "nil"

    Wd::Actions::ChangeAllPendingFiles.do @domain, filter

    { msg: "yeah" }.to_json
  end

  post '/pending/change', :provides => :json do
    WDLogger.debug "Changing permission for a pending file"
    Wd::Actions::ChangePendingFile.do params[:permissionId], @domain
    { msg: "yeah" }.to_json
  end

  post '/new-change-permissions', :provides => :json do
    WDLogger.debug 'Change Permissions'
    files = JSON.parse(params['files'])
    files_to_change = Files::FilesToChange.group_by_user files

    t1 = Thread.new{
      Watchdog::Global::Watchdog.changePermissions(files_to_change, @domain)
    }

    t1.join

    { :msg => "yeah" }.to_json
  end

  def to_domain_filter params_filter
    params_filter = nil if params_filter.eql? "nil"
    domain_filter = nil
    unless params_filter.nil?
      domain_filter = {}
      domain_filter[:pending] = params_filter["pending"].to_bool unless params_filter["pending"].nil?
      domain_filter[:oldOwner] = params_filter["oldOwner"] unless params_filter["oldOwner"].nil?
    end
    domain_filter
  end

end
