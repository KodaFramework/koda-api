require File.join(File.dirname(__FILE__), %w[mongo_collection])

class MongoDatabase
  def initialize database
   @db = database
  end
  
  def resource_collection_urls 
    resource_collections.map {|e| '/' + e }	    
  end
  
  def collection_links(user)
    all_user_collections(user.alias,user.isadmin).map do |collection|
      # TODO: may need to prefix this with rack mount location ie /api
      {'href' => '/' + collection, 'rel' => 'full', 'title' => collection, 'alias' => collection}
    end
  end
  
  def content_collection_links
    collections = all_user_collections('*',false).clone
    collections.map do |collection|
      { 'href' => '/content/' + collection.to_s, 'title' => collection.to_s }
    end
  end
  
  def all_user_collections(user,isadmin=false)
    user_collections = resource_collections.clone
    return user_collections if(isadmin)
    user_collections.each do |collection|
  	  access_control = collection(collection).find_document('access-control')
  	  if(access_control && access_control['read_users'] != "*" && !(access_control['read_users'].include? user))
  	    user_collections.delete collection
	    end
	  end
	  user_collections
  end
  
  def collection collection_name
    MongoCollection.new @db.collection(collection_name)
  end
  
  def resource_collections
    collections = @db.collection_names
  	collections.delete 'system.indexes'  
  	collections.delete 'system.users'  
  	collections.delete '_koda_meta'
  	collections.delete 'fs.chunks'  
  	collections.delete 'fs.files'
  	  	
    collections
  end
  
  def contains_collection collection_name
    resource_collections.include?(collection_name)  
  end
  
  def flat_file
    flat_file = []
      all_user_collections('*').each do |collection|

        if(collection != 'objectlabs-system' && collection != '_koda_media') 
          docs = collection(collection).content_links(nil, nil, nil)
          docs_in_collection = []
          docs.each do |doc|
            doc_from_db = collection(collection).find_document(doc['alias'])
            if(doc_from_db)
              docs_in_collection.push(doc_from_db.stripped_document)
            end
          end
          flat_file.push({'collection'=>collection, 'docs' => docs_in_collection})
        end
      end
    flat_file
  end
  
  def search(params, collection_name=nil)
    
    search_hash = Hash.new
    sort_hash = Hash.new

    if(params && params.length > 0)
      params.each do |k,v|
        if(v.include? '/')
          search_hash[k] = eval v
        else
          search_hash[k] = v
        end
        if (v == 'true' || v == 'false')
          search_hash[k] = v == 'true'
        end
        sort_hash[k] = 1
      end

      results = Hash.new
      
      if(collection_name)
        search_hash.delete 'collection'
        search_hash.delete 'splat'
        search_hash.delete 'captures'

        return collection(collection_name).query(search_hash, params[:take], params[:skip], sort_hash)
      end

      all_user_collections('*').each do |collection|
        collection_result = collection(collection).query(search_hash, params[:take], params[:skip], sort_hash)
        if(collection_result && collection_result.length > 0)
          results[collection] = collection_result
        end
      end
      
      results
  
    else
      flat_file
    end
    
  end
  
  def filter(collection_name, search_hash, take, skip)
    
    if(search_hash["sort"] != nil)
      sort_hash = search_hash["sort"]
    end

    search_hash["filter"].each do |k,v|
      if(v.include? '/')
        search_hash["filter"][k] = eval v
      else
        search_hash["filter"][k] = v
      end
    end

    collection(collection_name).query(search_hash["filter"], take, skip, sort_hash)
    
  end
  
end