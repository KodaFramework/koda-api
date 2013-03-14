require File.join(File.dirname(__FILE__), %w[resource_test_data])

class MongoTestData
  
  def self.collections
    collections = ResourceTestData.resources
    collections.each_pair do |collection_name, documents|
      documents.each do |doc|
        doc['_id'] = BSON::ObjectId(doc['id'])        
        doc.delete('id')
      end
    end
    collections['system.indexes']=[]
    collections['system.users']=[]
    collections
  end  
end