require File.join(File.dirname(__FILE__), %w[mongo_grid_io_double])
require 'singleton'

class MongoGridDouble
  include Singleton
  
  def initialize 
    @grid = {}
  end
  
  def put body, options
    object = MongoMedia.new 
    object.body = body 
    object.content_type = options[:content_type]
    object.last_updated = options[:metadata]
    id = rand(100000000)
    @grid[id] = object
    id
  end
  
  def delete id
    @grid.delete id
  end
  
  def get id
     found_media = @grid[id]
     
     if (found_media != nil)
       MongoGridIODouble.new @grid[id]       
     end
  end
  
end