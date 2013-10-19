require 'sinatra/base'
require_relative './authorisation/authorisation_methods'

module Koda
  module Authorisation
    class Content < Sinatra::Base
      include Koda::AuthorisationMethods

      configure do
        ENV['allow_anonymous'] = 'false'
      end

      def not_allowed(headers = {})
        headers.each do |key, value|
          response[key] = value
        end
        status 405
      end

      def authorise(auth_methods)
        default = lambda { not_allowed('Allow' => auth_methods.keys) }
        auth = auth_methods[request.request_method] || default
        is_authorised = auth.call
        halt 405 if not is_authorised
      end

      before do
        auth_methods = {
            'GET' => lambda { is_allowed? request.path_info, :get },
            'PUT' => lambda { is_allowed? request.path_info, :put },
            'DELETE' => lambda { is_allowed? request.path_info, :delete }
        }
        authorise auth_methods
      end
    end
  end
end