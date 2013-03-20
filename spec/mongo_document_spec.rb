require 'bson'
require 'time'
require_relative '../lib/koda-content/models/mongo_document'

describe 'Mongo Document' do
  
  it "returns a resource url based on id" do
    raw_doc = {'_id'=>BSON::ObjectId('4db0dedb387f7123c9000002'), 'title' => 'the title'}        
    
    doc = MongoDocument.new raw_doc, 'articles'
    doc.url.should == '/articles/4db0dedb387f7123c9000002'
  end
  
  it "has a title that is based on id" do
    raw_doc = {'_id'=>BSON::ObjectId('4db0dedb387f7123c9000002'), 'size'=>'small'}
    doc = MongoDocument.new raw_doc, 'shoes'        
    
    doc.title.should == '4db0dedb387f7123c9000002'
    
  end
  
  it "has a title that is based on override title" do
    raw_doc = {'_id'=>BSON::ObjectId('4db0dedb387f7123c9000002'), 'size'=>'small', '_koda_title' => 'A charming tale'}
    doc = MongoDocument.new raw_doc, 'shoes'        
    
    doc.title.should == 'A charming tale'
    
  end
  
  it "returns a resource url based on jam ref" do
    raw_doc = {'_id'=>BSON::ObjectId('4db0dedb387f7123c9000002'), 'alias'=>'uniquereference', 'title' => 'the title'}        
    
    doc = MongoDocument.new raw_doc, 'articles'
    doc.url.should == '/articles/uniquereference'
  end
  
  it "returns a resource url based on overriden" do
    raw_doc = {'_id'=>BSON::ObjectId('4db0dedb387f7123c9000002'), 'title' => 'the title'}        
    
    doc = MongoDocument.new raw_doc, 'articles', BSON::ObjectId('4db0dedb387f7123c9000006')
    doc.url.should == '/articles/4db0dedb387f7123c9000006'
  end
  
  it "standardised document has no id" do
    raw_doc = {'_id'=>BSON::ObjectId('4db0dedb387f7123c9000002'), 'title' => 'the title'}        
    
    doc = MongoDocument.new raw_doc, 'articles'
    doc.standardised_document['_id'].should be_nil
  end
  
  it "standardised document has a jam ref matching id" do
    raw_doc = {'_id'=>BSON::ObjectId('4db0dedb387f7123c9000002'), 'title' => 'the title'}        
    
    doc = MongoDocument.new raw_doc, 'articles'
    doc.standardised_document['alias'].should == '4db0dedb387f7123c9000002'     
  end

  it "standardised document has a jam ref matching id" do
    raw_doc = {'_id'=>BSON::ObjectId('4db0dedb387f7123c9000002'), 'alias'=>'uniquereference', 'title' => 'the title'}        
    
    doc = MongoDocument.new raw_doc, 'articles'
    doc.standardised_document['alias'].should == 'uniquereference'     
  end
  
  
  it "stores the last modified date when provided in constructor" do
    raw_doc = {'_id'=>BSON::ObjectId('4db0dedb387f7123c9000002'), 'title' => 'the title'}        
    
    time=Time.now.httpdate      
    doc = MongoDocument.new raw_doc, 'articles', nil, time     
    doc.last_modified.utc.should == Time.httpdate(time).utc
  end
  
end
