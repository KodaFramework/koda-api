require 'sinatra/base'
require 'koda-content/models/user'
require 'koda-content/models/document'
require 'koda-content/models/media'

module Koda
  module DocumentHelper
    def get_or_create_document(url)
      existing_document = Koda::Document.where(url: url).first
      is_new = existing_document.nil?
      existing_document = Koda::Document.for(request.path_info) if is_new
      {
          document: existing_document,
          is_new: is_new
      }
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
    url = request.path_info
    document = Koda::Document.where(url: url).first
    exists = !document.nil?
    status exists ? 200 : 404
    document.data.to_json if exists
  end

  get '/*.*' do
    url = request.path_info
    document = Koda::Document.where(url: url).first
    content_type document.data['storage']['content-type']
    Koda::Media.get(document.data)
  end

  get '/*' do
    Koda::Document.where(type: request.path_info).map{|document|
      data = document.data.dup
      data[:url] = document.url
      data
    }.to_json
  end

  put '/*.json' do
    document_data = JSON(request.env['rack.input'].read)

    res = get_or_create_document request.path_info
    res[:document].data = document_data
    res[:document].save

    status res[:is_new] ? 201 : 200
  end

  delete '/*.json' do
    existing_document = Koda::Document.where(url: request.path_info).first
    exists = !existing_document.nil?
    existing_document.delete if exists
    status exists ? 200 : 404
  end

  put '/*.*' do
    url = request.path_info

    media_storage_info = Koda::Media.put params[:media], url

    res = get_or_create_document url
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
  #
  #get '/_koda_media/:filename' do
  #  media = @grid_wrapper.get_media params[:filename]
  #
  #  if (media == nil)
  #    halt 404
  #  end
  #
  #  last_modified(media.last_updated)
  #
  #  content_type media.content_type
  #  body media.body
  #end
  #
  #put '/_koda_media/:filename?' do
  #  media = MongoMedia.new request, params
  #  file_name = @grid_wrapper.save_media(media, params[:filename])
  #
  #  new_location = '/_koda_media/' + file_name
  #
  #  response['Location'] = new_location
  #  status 200
  #  result = {
  #    'success' => 'true',
  #    'location' => new_location,
  #  }
  #  body result.to_json
  #end
  #
  #delete '/_koda_media/:filename?' do
  #  @grid_wrapper.delete_media(params[:filename])
  #end
  #
  #options '/_koda_media/:filename' do
  #  media = @grid_wrapper.get_media params[:filename]
  #
  #  if (media == nil)
  #    response['Allow'] = 'PUT'
  #    return
  #  end
  #
  #  response['Allow'] = 'GET,PUT,DELETE'
  #end
  #
  #
  #get '/:collection/?' do
  #  collection_name = params[:collection]
  #
  #  halt 404 if not @db_wrapper.contains_collection(collection_name)
  #  content_type :json, 'kodameta' => 'list'
  #
  #  sort = [['datecreated', Mongo::DESCENDING]]
  #
  #  #if(is_admin?)
  #    JSONP @db_wrapper.collection(collection_name).resource_links(params[:take], params[:skip], sort)
  #  # move this to another url
  #  #else
  #  #  JSONP @db_wrapper.collection(collection_name).resource_links_no_hidden(params[:take], params[:skip], sort)
  #  #end
  #end
  #
  #post '/:collection/?' do
  #  collection_name = params[:collection]
  #
  #  raw_doc = request.env["rack.input"].read
  #  hash = JSON.parse raw_doc
  #  new_doc = @db_wrapper.collection(collection_name).save_document(hash)
  #  refresh_cache
  #  response['Location'] = new_doc.url
  #  status 201
  #  result = {
  #    'success' => 'true',
  #    'location' => new_doc.url
  #  }
  #  body new_doc.url
  #end
  #
  #delete '/:collection/?' do
  #  collection_name = params[:collection]
  #  @db_wrapper.collection(collection_name).delete()
  #end
  #
  #options '/:collection/?' do
  #  halt 404 if not @db_wrapper.contains_collection(params[:collection])
  #  response['Allow'] = 'GET,POST,DELETE'
  #end
  #
  #
  #get '/:collection/:resource?' do
  #  collection_name = params[:collection]
  #
  #  doc_ref = params[:resource]
  #  should_include = params[:include] != 'false'
  #
  #  doc = @db_wrapper.collection(collection_name).find_document(doc_ref)
  #  halt 404 if doc==nil
  #  last_modified(doc.last_modified)
  #
  #  #fetch_linked_docs doc if should_include
  #
  #  JSONP doc.standardised_document
  #end
  #
  #put '/:collection/:resource' do
  #  collection_name = params[:collection]
  #
  #  resource_name = params[:resource]
  #  hash = JSON.parse request.env["rack.input"].read
  #
  #  if(hash['linked_documents'] != nil)
  #    hash.delete 'linked_documents'
  #  end
  #
  #  doc = @db_wrapper.collection(collection_name).save_document(hash, resource_name)
  #
  #  refresh_cache
  #
  #  status 201 if doc.is_new
  #
  #  response['Location'] = doc.url
  #
  #  body doc.url
  #end
  #
  #delete '/:collection/:resource' do
  #  collection_name = params[:collection]
  #  @db_wrapper.collection(collection_name).delete_document(params[:resource])
  #end
  #
  #options '/:collection/:resource' do
  #  collection_name = params[:collection]
  #  doc_ref = params[:resource]
  #
  #  doc = @db_wrapper.collection(collection_name).find_document(doc_ref)
  #
  #  if (doc==nil)
  #    response['Allow'] = 'PUT'
  #    return
  #  end
  #
  #  response['Allow'] = 'GET,PUT,DELETE'
  #end
  #
  #
  #options '*' do
  #end
end