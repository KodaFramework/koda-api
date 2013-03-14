class MongoGrid
  def initialize grid, meta_data_collection
    @grid = grid
    @meta_data_collection = meta_data_collection
  end
  
  def save_media media, file_name=nil
    map = media_map

    delete_media file_name
    id = @grid.put(media.body, {:content_type => media.content_type, :metadata => {'_koda_last_modified' => media.last_updated}.to_s })
    
    if (!file_name)
      file_name = id.to_s
    end
    
    map['media'][file_name] = id
    
    save_media_map map
    file_name
  end
  
  def delete_media key
    existing_id = get_id key

    if (existing_id)
      @grid.delete(existing_id)  
      
      delete_map = media_map
          
      delete_map['media'].delete(key)
      save_media_map delete_map
    end
  end

  def media_links
    media_map.raw_document['media'].keys.map do |name|
      {'href' => '/content/media/' + name.to_s, 'rel' => 'full', 'title' => name.to_s}      
    end    
  end

  def get_id key
    media_map['media'][key]
  end

  def get_media key
    id = get_id key
    
    begin
    file = @grid.get id
    rescue
    end
    
    if (file != nil)
            
      media = MongoMedia.new
      media.body = file.read
      media.content_type= file.content_type
      
      if(file.metadata)
        media.last_updated= file.metadata['_koda_last_modified']
        media
      else
        media
      end
    end
  end

  private
  
  def save_media_map map
    @meta_data_collection.save_document(map.raw_document, 'media_map')
  end
  
  def media_map
    doc = @meta_data_collection.find_document 'media_map'
        
    if (doc == nil)
      doc = MongoDocument.new({'media'=>{}}, 'media_map')
    end

    doc
  end
  
end