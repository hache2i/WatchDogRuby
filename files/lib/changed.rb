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

  end
end