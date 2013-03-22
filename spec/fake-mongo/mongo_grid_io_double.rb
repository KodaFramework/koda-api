
class MongoGridIODouble
  
  def initialize media
    @media = media
  end
  
  def read
    @media.body
  end
  
  def content_type
    @media.content_type
  end
  
  def metadata
    {'_koda_last_modified' => @media.last_updated}
  end
  
end