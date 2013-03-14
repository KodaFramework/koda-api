require 'time'

class MongoDocument
  attr_accessor :is_new
  
  def initialize doc, collection, id=nil, modified_time=nil
    @doc = doc
    @collection = collection
    
    if !(id == nil)
      @doc['_id'] = id
    end
        
    if !(modified_time==nil)
      @doc['_koda_last_modified']=modified_time
    end
  end
  
  def last_modified
    if !(@doc['_koda_last_modified']==nil)
      Time.httpdate(@doc['_koda_last_modified'])
    end
  end
    
  def id
    @doc['_id']
  end

  def id=(value)
    @doc['_id'] = value
  end
  
  def raw_document
    @doc
  end
  
  def []=(index, value)
    @doc[index] = value
  end
  
  def [](index)
    @doc[index] 
  end
  
  def standardised_document
    copy = @doc.clone
    copy['alias'] = ref
    copy.delete('_id')
    if(copy[:_id])
      copy.delete(:_id)
    end
    copy.delete('_koda_last_modified')
    copy
  end
  
  def title
    if (@doc['name'])
      @doc['name']
    else
      if(@doc['_koda_title'])
        @doc['_koda_title']
      else
        ref
      end
    end
  end
  
  def date_created
    return @doc['datecreated'] if(@doc['datecreated'])
    ''
  end
  
  def type
    if(@doc['_koda_type'])
      @doc['_koda_type'].to_s
    else
      'anon'
    end
  end
  
  def hidden 
    if(@doc['_koda_hidden_file'])
      true
    else
      false
    end
  end
  
  def doc_link 
    if(@doc['_koda_doc_links'])
      @doc['_koda_doc_links'].to_s
    else
      ''
    end
  end
  
  def stripped_document
    copy = @doc.clone
    copy.delete('_id')
    copy.delete('_koda_last_modified')
    copy.delete '_koda_indexes'
    copy.delete '_koda_type'
    copy.delete '_koda_editor'
    copy.delete '_koda_doc_links'
    copy.to_obj
  end

  def ref=(value)
      @doc['alias'] = value
  end
  
  def ref
    if (@doc['alias'] == nil)
      @doc['_id'].to_s
    else
      @doc['alias'].to_s
    end
  end
  
  def url
    # TODO: may need to prefix this with location where the app is mounted ie. /api
    '/' + @collection + '/' + ref
  end
  
end