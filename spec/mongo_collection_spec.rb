require 'bson'
require_relative '../lib/models/mongo_collection'

describe 'Mongo Collection' do
  
  it "provide a list document url and title" do
    raw_doc = {'_id'=>BSON::ObjectId('4db0dedb387f7123c9000002'), 'title' => 'the title'}        
    
    doc = MongoDocument.new raw_doc, 'articles'
    doc.url.should == '/articles/4db0dedb387f7123c9000002'
  end
  
  
end
