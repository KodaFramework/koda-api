require 'json'
require 'dalli'
require 'sinatra/base'
require 'rack-methodoverride-with-params'
require 'mongoid'

require 'koda-api/api'
require 'koda-api/media_storage/file_system'
require 'koda-api/models/media'


module Koda
  class Api < Sinatra::Base
    use Rack::MethodOverrideWithParams

    def options(path, opts={}, &block)
      route 'OPTIONS', path, opts, &block
    end

    Sinatra::Delegator.delegate :options

    before do
      content_type :json
      response['Access-Control-Allow-Origin'] = '*'
      response['Access-Control-Allow-Methods'] = 'PUT, DELETE, GET, POST, HEADER, OPTIONS'
      response['Access-Control-Allow-Headers'] = 'content-type'

      if (@env['HTTP_CACHE_CONTROL'] == 'no-cache')
        response['Cache-Control'] = 'no-cache'
        response['Pragma'] = 'no-cache'
      end
    end

    configure do
      Mongoid.configure do |config|
        config.sessions = {
            :default => {
                :hosts => ["localhost:27017"], :database => "koda"
            }
        }
      end

      set :protection, :except => [:remote_token, :frame_options, :json_csrf, :http_origin, :session_hijacking]
      set :public_folder, File.dirname(__FILE__) + '/public'

      set :view_format, :erb
      set :view_options, { :escape_html => true }

      set :environment, ENV['ENVIRONMENT'] if ENV['ENVIRONMENT']

      # --------------------------------------------------------------------------
      # Cache documents until they are changed (recommended for production)
      # To Use, set this env var to true
      # --------------------------------------------------------------------------
      if ENV['ENABLE_CACHE']
        set :enable_cache, ENV['ENABLE_CACHE']
      else
        set :enable_cache, false
      end

      set :allow_anonymous, ENV.has_key?('allow_anonymous') ? !!ENV['allow_anonymous'] : true
      Koda::MediaStorage::FileSystem.root_folder = File.join(Dir.pwd, 'media')
      Koda::Media.provider = Koda::MediaStorage::FileSystem
    end
  end
end
