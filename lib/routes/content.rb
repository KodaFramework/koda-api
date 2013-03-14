class Koda::Api
  get '/content?' do
    content_type :json, 'kodameta' => 'list'
    JSONP @db_wrapper.content_collection_links
  end

  get '/content/?' do
    content_type :json, 'kodameta' => 'list'
    JSONP @db_wrapper.content_collection_links
  end

  get '/content/search/?' do
    content_type :json, 'kodameta' => 'list'
    JSONP create_content
  end

  get '/content/search/:collection/?' do
    content_type :json, 'kodameta' => 'list'
    collection_name = params[:collection]
    JSONP @db_wrapper.search params,collection_name
  end

  get '/content/:collection/?' do
    content_type :json, 'kodameta' => 'list'
    collection_name = params[:collection]

    sort = [['datecreated', Mongo::DESCENDING]]

    halt 404 if not @db_wrapper.contains_collection(collection_name)
    JSONP @db_wrapper.collection(collection_name).content_links(params[:take], params[:skip], sort)
  end

  get '/content/:collection/:resource?' do
    collection_name = params[:collection]
    doc_ref = params[:resource]

    should_include = params[:include] != 'false'

    doc = @db_wrapper.collection(collection_name).find_document(doc_ref)
    halt 404 if doc==nil
    last_modified(doc.last_modified)

    #fetch_linked_docs doc if should_include

    JSONP doc.stripped_document
  end



  get '/content/media/:filename' do
    media = @grid_wrapper.get_media params[:filename]

    if (media == nil)
      halt 404
    end

    last_modified(media.last_updated)

    content_type media.content_type
    body media.body
  end
end