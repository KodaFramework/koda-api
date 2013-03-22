require 'bson'
require 'fake-mongo'
require_relative '../lib/koda-content/models/mongo_database'

describe 'Mongo Database' do

  it "outputs all user collections urls" do
    db = MongoDatabase.new MongoDbDouble.instance

    collections= db.resource_collection_urls

    collections.detect { |e| e == '/trucks'}.should_not be_nil
    collections.detect { |e| e == '/iguanas'}.should_not be_nil
    collections.detect { |e| e == '/cars'}.should_not be_nil
  end

  it "excludes system collections for urls" do
    db = MongoDatabase.new MongoDbDouble.instance

    collections= db.resource_collection_urls

    collections.detect { |e| e == '/system.indexes'}.should be_nil
    collections.detect { |e| e == '/system.users'}.should be_nil
  end


  it "outputs all user collections" do
    db = MongoDatabase.new MongoDbDouble.instance

    collections= db.resource_collections

    collections.detect { |e| e == 'trucks'}.should_not be_nil
    collections.detect { |e| e == 'iguanas'}.should_not be_nil
    collections.detect { |e| e == 'cars'}.should_not be_nil
  end

  it "excludes system collections" do
    db = MongoDatabase.new MongoDbDouble.instance

    collections= db.resource_collections

    collections.detect { |e| e == 'system.indexes'}.should be_nil
    collections.detect { |e| e == 'system.users'}.should be_nil
  end

  it "is able to find an existing collecton" do
    db = MongoDatabase.new MongoDbDouble.instance

    db.contains_collection('trucks').should be_true
  end

  it "cannot find an existing collecton" do
    db = MongoDatabase.new MongoDbDouble.instance

    db.contains_collection('birds').should_not be_true
  end

  it "cannot find an system collecton" do
    db = MongoDatabase.new MongoDbDouble.instance

    db.contains_collection('system.indexes').should_not be_true
  end


end
