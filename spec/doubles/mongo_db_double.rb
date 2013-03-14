require File.join(File.dirname(__FILE__), %w[../testdata/mongo_test_data])
require File.join(File.dirname(__FILE__), %w[mongo_collection_double])
require 'singleton'
require 'bson'

class MongoDbDouble
  include Singleton
  
  def initialize
    reset
  end
  
  def reset
    @collections = MongoTestData.collections
  end
  
  def collection_names
    @collections.keys
  end
  
  def collection name
    docs = @collections[name]
    
    if (docs == nil)
      docs = []
      @collections[name] = docs
    end
    
    CollectionDouble.new docs, name
  end
  
end
