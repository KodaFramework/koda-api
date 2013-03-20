require 'mongo'

class MongoConfig
  
  def self.GetGridFS
    db = GetMongoDatabase()

    Mongo::Grid.new db
  end

  def self.GetMongoDatabase 
    config = {:server => "localhost",:db => "koda"}
    p "Initiating mongo connection"

    if ENV['MONGOLAB_URI']
      p "using mongolabs"
  	  uri = URI.parse(ENV['MONGOLAB_URI'])
      conn = Mongo::Connection.from_uri(ENV['MONGOLAB_URI'])
      conn.db(uri.path.gsub(/^\//, ''))
    else
      p "using local mongo db"
  	  Mongo::Connection.new(config[:server],config[:port] || 27017).db(config[:db])
  	end
  end

end
