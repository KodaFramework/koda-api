module Koda
  module AuthorisationMethods
    def is_allowed?(action, collection_name)
      return false if !logged_in?

      access_control = find_access_control_for_collection(collection_name)
      return true if is_admin?
      return true if access_control == nil
      if (action == :read)
        read_users = access_control.read_users
        return true if is_public_read? collection_name
        return true if !read_users
        return true if read_users.include? current_user.alias
      elsif (action == :write)
        write_users = access_control.write_users
        return true if !write_users
        return true if write_users == "*"
        return true if write_users.include? current_user.alias
      elsif (action == :modify)
        modify_users = access_control.modify_users
        return true if modify_users == "*"
        return true if !modify_users
        return true if modify_users.include? current_user.alias
      end
      false
    end

    def is_public_read?(collection_name)
      access_control = find_access_control_for_collection(collection_name)
      return true if access_control == nil
      return true if access_control.read_users == "*"
    end

    def find_user(name)
      user = @db_wrapper.collection('users').find_document(name)
      if (user)
        return user.standardised_document.to_obj
      end
      nil
    end

    #
    #def authenticate(token)
    #  response = authenticate_with_janrain token
    #
    #  if(response["stat"] == "ok")
    #    id = response["profile"]["googleUserId"]
    #    name = response["profile"]["displayName"]
    #    email = response["profile"]["email"]
    #    ref = name.gsub(/\s+/, "-").downcase
    #    existing_user = find_user ref
    #
    #    if(existing_user)
    #      UserContext.current_user = existing_user
    #    else
    #      sign_up_user ref, id, name, email
    #    end
    #
    #    return true
    #  end
    #
    #  return false
    #end

    def current_user
      @env['koda_user']
    end

    def is_admin?
      current_user.isadmin
    end

    def is_allowed_in_console?
      current_user.isadmin
    end

    def is_allowed_in_explorer?
      current_user.isallowed
    end

    def logged_in?
      current_user != nil
    end

    def log_out
      current_user = nil
    end

    private

    def first_user?
      @db_wrapper.collection('users').resource_links.length == 0
    end

    #def create_user(user)
    #  new_user = @db_wrapper.collection('users').save_document(user)
    #  new_user.standardised_document.to_obj
    #end
    #
    #def authenticate_with_janrain(token)
    #  JSON.parse(
    #    RestClient.post("https://rpxnow.com/api/v2/auth_info",
    #      :token => token,
    #      :apiKey => settings.janrain_api_key,
    #      :format => "json",
    #      :extended => "true"
    #    )
    #  )
    #end

    #def sign_up_user(ref, id, name, email)
    #  is_admin = first_user?
    #  user = {
    #    'alias'=> ref,
    #    'googleid' => id,
    #    'name' => name,
    #    'email' => email,
    #    '_koda_indexes' => 'name,email',
    #    '_koda_type' => '/koda/koda-types/koda-user.json',
    #    '_koda_editor' => '/koda/koda-editors/generic-editor.html',
    #    'isadmin' => is_admin,
    #    'isallowed' => is_admin
    #  }
    #
    #  current_user = create_user(user)
    #end

    def db_wrapper
      env['koda_db']
    end

    def find_access_control_for_collection(collection_name)
      access_control = db_wrapper.collection(collection_name).find_document('access-control')
      if (access_control)
        return access_control.standardised_document.to_obj
      end
      nil
    end
  end
end
