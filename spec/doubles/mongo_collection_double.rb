require 'bson'
require 'mongo'
require File.join(File.dirname(__FILE__), %w[../testdata/mongo_test_data])

class CollectionDouble

  def initialize collection, name
    @collection = collection
    @name = name
  end
  
  def find spec_or_object_id=nil, options=nil    
    
    if !(spec_or_object_id == nil || spec_or_object_id == {})
      found = case spec_or_object_id
               when BSON::ObjectId
                 @collection.select {|item| item["_id"] == spec_or_object_id}
               when Hash
                 array = spec_or_object_id.to_a
                @collection.select {|item| item[array[0][0]] == array[0][1] }
               end      
    else
      found = @collection
    end
    
    

    take(skip(sort(found, options),options),options)
  end
  
  def name
    @name
  end
  
  def insert document    
    id = BSON::ObjectId("4db0dedb387f7123c9000010")
    document['_id'] = id
    @collection.push document    
    id
  end

  def save document    
    id = document['_id']
    @collection.delete_if {|e| e['_id'] == id }
    @collection.push document
    id
  end
  
  def find_one spec_or_object_id
    found = find spec_or_object_id    
    found.count == 0 ? nil : found[0]
  end
  
  def remove param=nil
  end
  
  def drop    
  end
  
  private 
  
  def take found, options
    take = get_option(options, :limit)
    if (take != nil)
      return found.take(take)                        
    else
      return found
    end
    
  end
  
  def sort found, options

    sort = get_option(options, :sort)

    if (sort != nil)
      sort = sort.first

      if sort.to_s != 'datecreated' && found[sort[0]]
        sorted = found.sort_by {|e| e[sort[0]]}
        sorted = sorted.reverse if (sort[1] == Mongo::DESCENDING)
        return sorted
      end
        return found
    else
      return found
    end
    
  end
  
  
  def get_option(options, key)
    return nil if options == nil
    return options[key]
  end
  
  def skip found, options
      skip = get_option(options, :skip)
      if (skip != nil)
        return found.slice(skip, found.count)                        
      else
        return found
      end
  end
  
end
