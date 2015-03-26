require 'mongoid'

module Files

  class Changed

    include Mongoid::Document
    include Mongoid::Timestamps::Created

    field :fileId, :type => String
    field :parentId, :type => String
    field :oldOwner, :type => String
    field :newOwner, :type => String
    field :title, :type => String
    field :pending, :type => Boolean

    def self.users domain
        where(domain: domain).distinct(:oldOwner)
    end

    def self.count_pending domain
        where(domain: domain, pending: true).count
    end

    def self.create_pending data
        already_pending = where fileId: data[:fileId], pending: true
        return unless already_pending.empty?
    	pending = data.merge pending: true
    	create pending
    end

    def self.pending_for_user user
        user_files = where(oldOwner: user, pending: true).desc(:created_at)
        user_files
    end

    def self.strfy_type file
        type = "Folder"
        type = "File" unless file.isFolder
        type
    end

  end
end