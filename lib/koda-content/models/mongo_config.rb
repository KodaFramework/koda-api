require 'mongo'

class MongoConfig
  
  def self.GetGridFS
    db = GetMongoDatabase()

    Mongo::Grid.new db
  end

  def self.GetMongoDatabase 
    config = {:server => "localhost",:db => "koda"}

    if ENV['MONGOLAB_URI']
  	  uri = URI.parse(ENV['MONGOLAB_URI'])
      conn = Mongo::Connection.from_uri(ENV['MONGOLAB_URI'])
      conn.db(uri.path.gsub(/^\//, ''))
    else
  	  Mongo::Connection.new(config[:server],config[:port] || 27017).db(config[:db])
  	end
  end

end
