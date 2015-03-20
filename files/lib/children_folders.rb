require_relative 'user_files'

module Files
  class Children
    def initialize(theDriveConnection, theUsers, theFolders, domain_data)
      theDriveConnection.authorize(domain_data.docaccount)
      @users = theUsers
      @domain_data = domain_data
      @commands = theFolders.map do |folder|
        FolderChildren.new theDriveConnection, theUsers, folder, domain_data
      end
    end

    def get
      children = []
      @commands.each do |command|
        command.exec
        children.concat command.children
        WDLogger.debug "getting files for #{ @users } - #{ command.children.length } more added (not finished yet - #{children.length.to_s} until now)", @domain_data.name, @users unless command.children.empty?
        @commands.concat command.commands
      end
      WDLogger.debug "getting files for #{ @users } - #{ children.length } - FINISHED", @domain_data.name, @users
    end

  end

  class FolderChildren

    attr_accessor :children, :commands

    def initialize theDriveConnection, theUsers, theFolder, domain_data, path = ""
      @path = "#{path}/#{theFolder[:title]}"
      @users = theUsers
      @folder = theFolder
      @driveConnection = theDriveConnection
      @commands = []
      @children = []
      @domain_data = domain_data
    end

    def exec
      WDLogger.debug "checking folder #{@folder.inspect}", @domain_data.name, @users
      begin
        result = DriveApiHelper.list_files @driveConnection, assembleParams(getPageToken(result))
        break unless result.success?
        result.data.items.each do |item|
          childData = build_child_data item

          if is_from_any_of_the_users(item)
            change_proposal = changed childData
            Changed.create_pending change_proposal
            @children << "bla"
          end
          should_be_added_to_check = is_a_folder(item) && (is_from_docaccount(item) || is_from_any_of_the_users(item))
          @commands << FolderChildren.new(@driveConnection, @users, childData, @domain_data, @path) if should_be_added_to_check
        end
      end while hasNextPage? result
    end

    def is_from_docaccount item
      !(item["owners"].find_all { |item| @domain_data.docaccount == item["emailAddress"] }).empty?
    end

    def is_from_any_of_the_users item
      !(item["owners"].find_all { |item| @users.include? item["emailAddress"] }).empty?
    end

    def is_a_folder item
      item["mimeType"].eql? "application/vnd.google-apps.folder"
    end

    def build_child_data item
      current_owners = item['owners'].map{ |owner| owner["emailAddress"] }
      { 
        :title => item['title'], 
        :id => item['id'], 
        :owner => current_owners, 
        :parent => @folder[:id],
        :isFolder => is_a_folder(item)
      }
    end

    def changed fileData
      {
        :fileId => fileData[:id],
        :oldOwner => fileData[:owner].first,
        :newOwner => @domain_data.docaccount,
        :parentId => fileData[:parent],
        :title => fileData[:title],
        :domain => @domain_data.name,
        :path => @path,
        :isFolder => fileData[:isFolder]
      }
    end

    def assembleParams pageToken
      not_trashed = "trashed = false"
      child_of_folder = "'" + @folder[:id] + "' in parents"

      each_user_in_owners_subqueries = @users.inject([]) do |subqueries, user|
        subqueries << "('" + user + "' in owners)"
      end

      from_users = "(#{each_user_in_owners_subqueries.join(' or ')})"

      is_folder = "(mimeType = 'application/vnd.google-apps.folder')"
      is_not_folder = "(mimeType != 'application/vnd.google-apps.folder')"

      query = myand [not_trashed, child_of_folder, myor([myand([from_users, is_not_folder]), is_folder])]

      params = { 'q' => query }
      params.merge!('pageToken' => pageToken) if !pageToken.empty?
      params
    end

    def myand params
      query = params.inject{ |query, param| query = query + " and " + param }
      "(" + query + ")"
    end

    def myor params
      query = params.inject{ |query, param| query = query + " or " + param }
      "(" + query + ")"
    end

    def getPageToken(result)
      return '' if result.nil? || result.data.nil?
      return result.data.next_page_token if hasNextPage? result
      ''
    end

    def hasNextPage?(result)
      !result.data.next_page_token.nil? && !result.data.next_page_token.empty?
    end

  end
end