require_relative '../lib/models/mongo_grid'
require_relative '../lib/models/mongo_media'
require_relative '../lib/models/mongo_collection'
require_relative './doubles/mongo_grid_double'
require_relative './doubles/mongo_db_double'
require 'json'

describe 'Mongo Grid' do

  it "adds a file to the directory" do
    db = MongoDbDouble.instance
    grid = MongoGrid.new(MongoGridDouble.instance,MongoCollection.new(db.collection('_koda_meta')))
    media = MongoMedia.new
    media.content_type = 'text/plain'
    media.body = 'just some plain text'

    grid.save_media media, 'abc123'
    fetched = grid.get_media 'abc123'

    fetched.body.should == 'just some plain text'
    fetched.content_type.should == 'text/plain'
  end


  it "sets the last updated date" do
    db = MongoDbDouble.instance
    grid = MongoGrid.new(MongoGridDouble.instance,MongoCollection.new(db.collection('_koda_meta')))
    media = MongoMedia.new
    media.content_type = 'text/plain'
    media.body = 'just some plain text'
    media.last_updated = Time.now.httpdate

    grid.save_media media, 'abc123'
    fetched = grid.get_media 'abc123'

    fetched.body.should == 'just some plain text'
    fetched.content_type.should == 'text/plain'
    fetched.last_updated.should_not be_nil
  end


  it "file is replaced when saved twice" do
    db = MongoDbDouble.instance
    grid = MongoGrid.new(MongoGridDouble.instance,MongoCollection.new(db.collection('_koda_meta')))

    media = MongoMedia.new
    media.content_type = 'text/plain'
    media.body = 'just some plain text'

    media2 = MongoMedia.new
    media2.content_type = 'text/plain'
    media2.body = 'just some plain text part 2'

    grid.save_media media, 'abc123'
    grid.save_media media2, 'abc123'

    fetched = grid.get_media 'abc123'

    fetched.body.should == 'just some plain text part 2'
    fetched.content_type.should == 'text/plain'
  end

  it "adds a file to the directory when no specific url given" do
    db = MongoDbDouble.instance
    grid = MongoGrid.new(MongoGridDouble.instance,MongoCollection.new(db.collection('_koda_meta')))

    media = MongoMedia.new
    media.content_type = 'text/plain'
    media.body = 'just some plain text'

    url = grid.save_media media
    fetched = grid.get_media url

    fetched.body.should == 'just some plain text'
    fetched.content_type.should == 'text/plain'
  end

  it "returns links to media" do
    db = MongoDbDouble.instance
    grid = MongoGrid.new(MongoGridDouble.instance,MongoCollection.new(db.collection('_koda_meta')))

    media = MongoMedia.new
    media.content_type = 'text/plain'
    media.body = 'just some plain text'

    grid.media_links
  end

  it "deletes media" do
    db = MongoDbDouble.instance
    grid = MongoGrid.new(MongoGridDouble.instance,MongoCollection.new(db.collection('_koda_meta')))

    media = MongoMedia.new
    media.content_type = 'text/plain'
    media.body = 'just some plain text'
    key = grid.save_media media
    fetched = grid.get_media key
    fetched.should_not be_nil

    grid.delete_media key

    fetched2 = grid.get_media key

    fetched2.should be_nil

  end

  it "two media files added are both retrievable" do
    db = MongoDbDouble.instance
    grid = MongoGrid.new(MongoGridDouble.instance,MongoCollection.new(db.collection('_koda_meta')))

    media1 = MongoMedia.new
    media1.content_type = 'text/plain'
    media1.body = 'just some plain text'
    url1 = grid.save_media media1

    media2 = MongoMedia.new
    media2.content_type = 'text/html'
    media2.body = '<h1></h1>'
    url2 = grid.save_media media2

    fetched1 = grid.get_media url1
    fetched2 = grid.get_media url2

    fetched1.body.should == 'just some plain text'
    fetched1.content_type.should == 'text/plain'

    fetched2.body.should == '<h1></h1>'
    fetched2.content_type.should == 'text/html'

  end




end
