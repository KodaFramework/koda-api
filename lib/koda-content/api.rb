require 'sinatra/base'
require 'koda-content/models/user'
require 'koda-content/models/document'
require 'koda-content/models/media'

module Koda
  module DocumentHelper
    def get_or_create_document(uri)
      existing_document = Koda::Document.where(uri: uri).first
      is_new = existing_document.nil?
      existing_document = Koda::Document.for(uri) if is_new
      {
          document: existing_document,
          is_new: is_new
      }
    end

    def uri
      request.path_info.gsub request.script_name, ''
    end
  end
end

class Koda::Api < Sinatra::Base
  include Koda::DocumentHelper
  before do
    env['koda_user'] = Koda::User.new({is_admin: true, alias: 'anonymous'}) if settings.allow_anonymous and not env.has_key?('koda_user')
    halt 405, "You must either use an authorisation provider, or set :anonymous, true" if not env.has_key?('koda_user')
  end

  def current_user
    env['koda_user']
  end

  get '/*.json' do
    document = Koda::Document.where(uri: uri).first
    exists = !document.nil?
    status exists ? 200 : 404
    document.data.to_json if exists
  end

  get '/*.*' do
    document = Koda::Document.where(uri: uri).first
    content_type document.data['storage']['content-type']
    Koda::Media.get(document.data)
  end

  get '/*' do
    Koda::Document.where(type: uri).map{|document|
      data = document.data.dup
      data[:url] = File.join(request.script_name, document.uri)
      data
    }.to_json
  end

  put '/*.json' do
    document_data = JSON(request.env['rack.input'].read)

    res = get_or_create_document uri
    res[:document].data = document_data
    res[:document].save

    status res[:is_new] ? 201 : 200
  end

  delete '/*.json' do
    existing_document = Koda::Document.where(uri: uri).first
    exists = !existing_document.nil?
    existing_document.delete if exists
    status exists ? 200 : 404
  end

  put '/*.*' do
    media_storage_info = Koda::Media.put params[:media], uri

    res = get_or_create_document uri
    res[:document].data = {storage: media_storage_info}
    res[:document].save

    status res[:is_new] ? 201 : 200
  end


  options '/' do
    response['Allow'] = 'GET'
  end

  get '/session/current_user' do
    JSONP current_user
  end
end