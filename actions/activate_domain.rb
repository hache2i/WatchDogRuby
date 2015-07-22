require_relative '../wdadmin/lib/domains'
require_relative '../wdadmin/lib/activate_domain_wrong_params'
require_relative '../users/lib/docs_admins'

module Wd
    module Actions
        class ActivateDomain

            def self.do domain, docs_admin, licenses
                checkParams(domain, docs_admin, licenses)
                Watchdog::Global::Domains.activate domain, licenses
                domain_docs_admin = Users::DocsAdmins.find_or_create_by(domain: domain)
                domain_docs_admin.update_attributes(admin: docs_admin)
            end

            private

            def self.checkParams (domain, docs_admin, licenses)
                raise ActivateDomainWrongParams.new "activate.domain.docsadmin.required" if notValid docs_admin
                raise ActivateDomainWrongParams.new "activate.domain.domain.required" if notValid domain
                raise ActivateDomainWrongParams.new "activate.domain.licenses.required" if notValid licenses
            end

            def self.notValid(field)
                field.nil? || field.empty?
            end

        end
    end
end