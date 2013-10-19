require 'koda-api/models/document'

module Koda
  module AuthorisationMethods

    def get_acl(type)
      Koda::Document.where(type: type, name: 'access-control.json').first
    end

    def is_allowed?(url, action)
      acl_document = get_acl File.dirname url
      acl = acl_document.data unless acl_document.nil?

      return true if acl.nil?
      #return true if is_admin?

      has_access? acl[action.to_s]
    end

    def has_access?(access_list)
      access_list.nil? || access_list == '*' || access_list.include?(current_user_name)
    end

    def current_user
      @env['koda_user']
    end

    def current_user_name
      current_user ? current_user.name : 'anonymous'
    end

    def is_admin?
      current_user ? current_user.is_admin? : false
    end
  end
end
