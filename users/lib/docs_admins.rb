require 'mongoid'

module Users

    class DocsAdmins

        include Mongoid::Document

        field :domain, :type => String
        field :admin, :type => String

    end
end