require 'sinatra/base'

class Koda::Api < Sinatra::Base
  before '/*' do
    env['koda_user'] = {isadmin: true, isallowed: true, alias: 'anonymous'} if settings.allow_anonymous and not env.has_key?('koda_user')
    halt 405, "You must either use an authorisation provider, or set :anonymous, true" if not env.has_key?('koda_user')
  end

  def current_user
    env['koda_user']
  end

  get '/koda/*' do
    response['Allow'] = 'GET'
    path = File.dirname(__FILE__) + '/../../public' + request.path
    response['Content-Type'] = 'text/css' if path =~ /.css$/
    response['Content-Type'] = 'text/javascript' if path =~ /.js$/
    response['Content-Type'] = 'image/jpeg' if path =~ /.jpg$/
    response['Content-Type'] = 'image/png' if path =~ /.png$/
    response['Content-Type'] = 'image/gif' if path =~ /.gif/
    response['Content-Type'] = 'text/html' if path =~ /.html/
    File.open(path, 'rb') {|f| f.read}
  end

  get '/' do
    content_type :json, 'kodameta' => 'list'
    JSONP @db_wrapper.collection_links current_user
  end

  options '/' do
    response['Allow'] = 'GET'
  end

  get '/session/current_user' do
    JSONP current_user
  end

  options '/_koda_media/?' do
    response['Allow'] = 'GET,POST'
  end


  get '/_koda_media/?' do
    content_type :json, 'kodameta' => 'list'
    media = @grid_wrapper.media_links.to_json
  end

  post '/_koda_media/?' do
    media = MongoMedia.new request, params
    file_name = @grid_wrapper.save_media media

    new_location = '/content/media/' + file_name

    response['Location'] = new_location
    status 200
    result = {
      'success' => 'true',
      'location' => new_location,
    }
    body result.to_json
  end

  get '/_koda_media/:filename' do
    media = @grid_wrapper.get_media params[:filename]

    if (media == nil)
      halt 404
    end

    last_modified(media.last_updated)

    content_type media.content_type
    body media.body
  end

  put '/_koda_media/:filename?' do
    media = MongoMedia.new request, params
    file_name = @grid_wrapper.save_media(media, params[:filename])

    new_location = '/_koda_media/' + file_name

    response['Location'] = new_location
    status 200
    result = {
      'success' => 'true',
      'location' => new_location,
    }
    body result.to_json
  end

  delete '/_koda_media/:filename?' do
    @grid_wrapper.delete_media(params[:filename])
  end

  options '/_koda_media/:filename' do
    media = @grid_wrapper.get_media params[:filename]

    if (media == nil)
      response['Allow'] = 'PUT'
      return
    end

    response['Allow'] = 'GET,PUT,DELETE'
  end


  get '/:collection/?' do
    collection_name = params[:collection]

    halt 404 if not @db_wrapper.contains_collection(collection_name)
    content_type :json, 'kodameta' => 'list'

    sort = [['datecreated', Mongo::DESCENDING]]

    #if(is_admin?)
      JSONP @db_wrapper.collection(collection_name).resource_links(params[:take], params[:skip], sort)
    # move this to another url
    #else
    #  JSONP @db_wrapper.collection(collection_name).resource_links_no_hidden(params[:take], params[:skip], sort)
    #end
  end

  post '/:collection/?' do
    collection_name = params[:collection]

    raw_doc = request.env["rack.input"].read
    hash = JSON.parse raw_doc
    new_doc = @db_wrapper.collection(collection_name).save_document(hash)
    refresh_cache
    response['Location'] = new_doc.url
    status 201
    result = {
      'success' => 'true',
      'location' => new_doc.url
    }
    body new_doc.url
  end

  delete '/:collection/?' do
    collection_name = params[:collection]
    @db_wrapper.collection(collection_name).delete()
  end

  options '/:collection/?' do
    halt 404 if not @db_wrapper.contains_collection(params[:collection])
    response['Allow'] = 'GET,POST,DELETE'
  end


  get '/:collection/:resource?' do
    collection_name = params[:collection]

    doc_ref = params[:resource]
    should_include = params[:include] != 'false'

    doc = @db_wrapper.collection(collection_name).find_document(doc_ref)
    halt 404 if doc==nil
    last_modified(doc.last_modified)

    #fetch_linked_docs doc if should_include

    JSONP doc.standardised_document
  end

  put '/:collection/:resource' do
    collection_name = params[:collection]

    resource_name = params[:resource]
    hash = JSON.parse request.env["rack.input"].read

    if(hash['linked_documents'] != nil)
      hash.delete 'linked_documents'
    end

    doc = @db_wrapper.collection(collection_name).save_document(hash, resource_name)

    refresh_cache

    status 201 if doc.is_new

    response['Location'] = doc.url

    body doc.url
  end

  delete '/:collection/:resource' do
    collection_name = params[:collection]
    @db_wrapper.collection(collection_name).delete_document(params[:resource])
  end

  options '/:collection/:resource' do
    collection_name = params[:collection]
    doc_ref = params[:resource]

    doc = @db_wrapper.collection(collection_name).find_document(doc_ref)

    if (doc==nil)
      response['Allow'] = 'PUT'
      return
    end

    response['Allow'] = 'GET,PUT,DELETE'
  end


  options '*' do
  end
end