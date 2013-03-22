require 'sinatra/base'
require_relative './authorisation/authorisation_methods'

module Koda
  module Authorisation
    class Content < Sinatra::Base
      include Koda::AuthorisationMethods

      configure do
        ENV['allow_anonymous'] = 'false'
      end

      before do
        # TODO: get this information from a real location
        #env['koda_user'] = {
        #    :isadmin => true,
        #    :isallowed => true,
        #    :alias => 'derek'
        #}
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

      before '/' do
        auth_methods = {
            'GET' => lambda { logged_in? }
        }
        authorise auth_methods
      end

      before '/_koda_media/?' do
        auth_methods = {
            'GET' => lambda { true },
            'POST' => lambda { logged_in? }
        }
        authorise auth_methods
      end

      before '/_koda_media/:filename/?' do
        auth_methods = {
            'GET' => lambda { true },
            'PUT' => lambda { logged_in? },
            'POST' => lambda { logged_in? },
            'DELETE' => lambda { logged_in? }
        }
        authorise auth_methods
      end

      before '/content/:collection/?' do
        collection_name = params[:collection]

        auth_methods = {
            'GET' => lambda { is_public_read? collection_name }
        }
        authorise auth_methods
      end

      before '/:collection/?' do
        collection_name = params[:collection]
        auth_methods = {
            'GET' => lambda { is_allowed? :read, collection_name },
            'POST' => lambda { is_allowed? :write, collection_name },
            'DELETE' => lambda { is_allowed? :modify, collection_name }
        }

        authorise auth_methods
      end

      before '/:collection/:resource/?' do
        collection_name = params[:collection]
        auth_methods = {
            'GET' => lambda { is_allowed? :read, collection_name },
            'POST' => lambda { is_allowed? :write, collection_name },
            'PUT' => lambda { is_allowed? :write, collection_name },
            'DELETE' => lambda { is_allowed? :modify, collection_name }
        }

        authorise auth_methods
      end
    end
  end
end