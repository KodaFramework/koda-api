require 'rack/test'
require 'json'
require_relative './testdata/resource_test_data'
require 'time'

shared_examples_for "Mongo KodaRms write interface" do
  it "accepts a resource into an existing collection" do
    header 'Content-Type', 'application/json;charset=utf-8'
    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27 }.to_json
    post '/bikes', bike, env

    last_response.status.should == 201
    last_response.location.should start_with '/bikes/'
    last_response.body.should start_with '/bikes/'
    last_response.content_type.should == 'application/json;charset=utf-8'
  end

  it "actually creates the resource added into an existing collection" do
    header 'Content-Type', 'application/json;charset=utf-8'
    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27 }.to_json
    post '/bikes', bike, env

    last_response.status.should == 201
    get last_response.location, {}, env

    last_response.should be_ok
    response_json = JSON.parse last_response.body
    response_json['alias'].should_not be_nil
    response_json['cost'].should == 'expensive'
    response_json['speed'].should == 'fast'
    response_json['gears'].should == 27
  end

  it "should hide folders with access-control set to non-public" do
    header 'Content-Type', 'application/json;charset=utf-8'
    access_control = { 'read_users' => '-', 'alias' => 'access-control' }.to_json
    post '/bikes', access_control, env

    last_response.status.should == 201
    get '/content', {}, env

    puts last_response.body

    last_response.body.should_not include '/bikes'
  end

  # TODO: ensure these cases are covered in the authorisation module
  #it "should deny access to folders with access-control set to non-public" do
  #  header 'Content-Type', 'application/json;charset=utf-8'
  #  access_control = { 'read_users' => '-', 'alias' => 'access-control' }.to_json
  #  post '/bikes', access_control
  #
  #  last_response.status.should == 201
  #  get '/content/bikes'
  #
  #  last_response.status.should == 405
  #end
  #
  #it "should deny access to documents with parent folder access-control set to non-public" do
  #  header 'Content-Type', 'application/json;charset=utf-8'
  #  bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'fastexpensiveone' }.to_json
  #  post '/bikes', bike
  #
  #  access_control = { 'read_users' => '-', 'alias' => 'access-control' }.to_json
  #  post '/bikes', access_control
  #
  #  last_response.status.should == 201
  #  get '/content/bikes/fastexpensiveone'
  #
  #  last_response.status.should == 405
  #end

  it "creates a resource at the right location when jam ref supplied" do
    header 'Content-Type', 'application/json;charset=utf-8'
    bike = {'alias'=>'thefastexpensiveone','cost' => 'expensive', 'speed' => 'fast', 'gears' => 27 }.to_json
    post '/bikes', bike, env

    last_response.status.should == 201
    last_response.location.should == '/bikes/thefastexpensiveone'

    get last_response.location, {}, env

    last_response.should be_ok
    response_json = JSON.parse last_response.body
    response_json['alias'].should_not be_nil
    response_json['cost'].should == 'expensive'
    response_json['speed'].should == 'fast'
    response_json['gears'].should == 27
  end

  it "creates a media at the right location" do
       header 'Content-Type', 'text/plain'
       content = 'just some normal plain text, nothing special'
       post '/_koda_media', content, env

       last_response.status.should == 200
       last_response.location.should start_with '/content/media/'

       last_response.body.should include '/content/media/'
       last_response.content_type.should == 'application/json;charset=utf-8'
  end

  it "create retrievable media at the right location" do
       header 'Content-Type', 'text/plain'
       content = 'just some normal plain text, nothing special'
       post '/_koda_media', content, env

       get last_response.location, {}, env

       last_response.should be_ok
       last_response.body.should == 'just some normal plain text, nothing special'
       last_response.content_type.should start_with 'text/plain'
  end

  it "creates retrievable media at the right location" do
       header 'Content-Type', 'text/plain'
       content = 'just some normal plain text, nothing special'
       put '/_koda_media/thisisthename', content, env

       get last_response.location, {}, env

       last_response.should be_ok
       last_response.body.should == 'just some normal plain text, nothing special'
       last_response.content_type.should start_with 'text/plain'
  end

  it "creates retrievable media from multipart form with many files at the right location" do

       put '/_koda_media/thisisthename', {'files[]' => Rack::Test::UploadedFile.new('spec/testdata/IMG_0380.JPG', 'image/jpg')}, env

       get last_response.location, {}, env

       last_response.should be_ok
       last_response.content_type.should start_with 'image/jpg'
  end

  it "creates retrievable media from multipart form with many files at the right location with correct file contents" do

       put '/_koda_media/thisisthename', {'files[]' => Rack::Test::UploadedFile.new('spec/testdata/simpletext.txt', 'text/plain')}, env

       get last_response.location, {}, env

       last_response.should be_ok
       last_response.content_type.should start_with 'text/plain'
       last_response.body.should == 'some simple text'

  end

  it "creates retrievable media from multipart form with many files at the right location" do

       put '/_koda_media/thisisthename', {'file' => Rack::Test::UploadedFile.new('spec/testdata/IMG_0380.JPG', 'image/jpg')}, env

       get last_response.location, {}, env

       last_response.should be_ok
       last_response.content_type.should start_with 'image/jpg'
  end

  it "creates retrievable media from multipart form with many files at the right location with correct file contents" do

       put '/_koda_media/thisisthename', {'file' => Rack::Test::UploadedFile.new('spec/testdata/simpletext.txt', 'text/plain')}, env

       get last_response.location, {}, env

       last_response.should be_ok
       last_response.content_type.should start_with 'text/plain'
       last_response.body.should == 'some simple text'
  end

  it "creates retrievable media from multipart form with many files at the right location with correct file contents" do

       post '/_koda_media', {'file' => Rack::Test::UploadedFile.new('spec/testdata/simpletext.txt', 'text/plain')}, env

       get last_response.location

       last_response.should be_ok
       last_response.content_type.should start_with 'text/plain'
       last_response.body.should == 'some simple text'
  end


  it "accepts a resource into an existing collection when trailing slash added" do
    header 'Content-Type', 'application/json;charset=utf-8'
    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27 }.to_json
    post '/bikes/', bike, env

    last_response.status.should == 201
    last_response.location.should start_with '/bikes/'
    last_response.body.should start_with '/bikes/'
    last_response.content_type.should == 'application/json;charset=utf-8'
  end

  it "creates a new resource at a set location through put" do
    header 'Content-Type', 'application/json;charset=utf-8'
    new_truck = {'size' => 'biggest', 'speed' => 'fast', 'gears' => 27 }.to_json

    put '/trucks/4db0dedb387f7123c9900001', new_truck, env

    last_response.status.should == 201
    get last_response.location, {}, env

    last_response.should be_ok
    response_json = JSON.parse last_response.body
    response_json['alias'].should_not be_nil
    response_json['size'].should == 'biggest'
    response_json['speed'].should == 'fast'
    response_json['gears'].should == 27
  end

  it "creates a new resource at a set non-id location through put" do
    header 'Content-Type', 'application/json;charset=utf-8'
    new_truck = {'size' => 'biggest', 'speed' => 'fast', 'gears' => 27 }.to_json

    put '/trucks/bigone', new_truck, env

    last_response.status.should == 201
    last_response.location.should == '/trucks/bigone'
    get last_response.location, {}, env

    last_response.should be_ok
    response_json = JSON.parse last_response.body
    response_json['alias'].should_not be_nil
    response_json['size'].should == 'biggest'
    response_json['speed'].should == 'fast'
    response_json['gears'].should == 27
  end

  it "replaces an existing resource through put" do
    header 'Content-Type', 'application/json;charset=utf-8'
    new_truck = {'size' => 'anupdatedvalue', 'speed' => 'fast', 'gears' => 27 }.to_json

    put '/trucks/4db0dedb387f7123c9000001', new_truck, env
    puts "error"
    puts last_response.errors
    puts last_response.status
    last_response.status.should == 201

    get '/trucks/4db0dedb387f7123c9000001', {}, env
    last_response.should be_ok
    response_json = JSON.parse last_response.body
    response_json['size'].should == 'anupdatedvalue'
  end

  it "replaces an existing resource through put to overridden ref" do
    header 'Content-Type', 'application/json;charset=utf-8'
    new_truck = {'alias'=>'smallblueone','size' => 'anupdatedvalue', 'speed' => 'fast', 'gears' => 27 }.to_json

    put '/trucks/smallblueone', new_truck, env
    last_response.status.should == 201

    get '/trucks/smallblueone', {}, env
    last_response.should be_ok
    response_json = JSON.parse last_response.body
    response_json['size'].should == 'anupdatedvalue'
  end

  it "replaces an existing resource through put method override of post" do
    header 'Content-Type', 'application/json;charset=utf-8'
    new_truck = {'size' => 'anupdatedvalue', 'speed' => 'fast', 'gears' => 27 }.to_json

    post '/trucks/4db0dedb387f7123c9000001?_method=put', new_truck, env
    last_response.should be_ok

    get '/trucks/4db0dedb387f7123c9000001', {}, env
    puts "status"
    puts last_response.status
    last_response.should be_ok
    response_json = JSON.parse last_response.body
    response_json['size'].should == 'anupdatedvalue'
  end


  it "removes an existing resource through delete" do
    delete '/trucks/4db0dedb387f7123c9000002', {}, env
    last_response.should be_ok
  end

  it "removes an existing resource through delete of friendly url" do
    delete '/trucks/smallblueone', {}, env
    last_response.should be_ok
  end

  it "removes an existing collection through delete" do
    delete '/trucks/', {}, env
    last_response.should be_ok
  end

  it "removes an existing resource through post faked delete" do
    post '/trucks/4db0dedb387f7123c9000002?_method=delete', {}, env
    last_response.should be_ok
  end

end

shared_examples_for "Mongo KodaRms options interface" do
  it "returns just get option for root" do
    options ''

    last_response.should be_ok
    last_response.headers['Allow'].should == 'GET'
  end

  it "returns get and post for media dir" do
    options '/_koda_media/'

    last_response.should be_ok
    last_response.headers['Allow'].should == 'GET,POST'
  end

  it "returns get, post and delete for collection dir" do
    options '/_koda_media/'

    last_response.should be_ok
    last_response.headers['Allow'].should == 'GET,POST'
  end


  it "returns get, post and delete for collection dir" do
    options '/trucks/', {}, env

    puts "=================="
    p last_response.errors
    last_response.should be_ok
    last_response.headers['Allow'].should == 'GET,POST,DELETE'
  end

  it "returns get, put and delete for resource" do
    options '/trucks/smallblueone', {}, env

    last_response.should be_ok
    last_response.headers['Allow'].should == 'GET,PUT,DELETE'
  end

  it "returns just put for non-existent resource" do
    options '/trucks/smallredone', {}, env

    last_response.should be_ok
    last_response.headers['Allow'].should == 'PUT'
  end


end

shared_examples_for "Mongo KodaRms read interface" do
  it "returns a non-empty list of collection urls at the root" do
    get '/', {}, env

    last_response.should be_ok
    response_json = JSON.parse last_response.body
    response_json.count.should > 0
  end

  it "returns the correct collections at root" do
    get '/', {}, env

    response_json = JSON.parse last_response.body
    response_json.detect { |e| e['href'] == '/iguanas'}.should_not be_nil
    response_json.detect { |e| e['href'] == '/trucks'}.should_not be_nil
    response_json.detect { |e| e['href'] == '/cars'}.should_not be_nil
  end

  it "should not include the media folder at root" do
    get '/', {}, env

    response_json = JSON.parse last_response.body
    response_json.detect { |e| e['href'] == '/_koda_media'}.should be_nil
  end


  it "returns a non-empty list of resource urls from the trucks collection" do
    get '/trucks', {}, env

    last_response.should be_ok
    response_json = JSON.parse last_response.body
    response_json.count.should > 0
  end


  it "accepts the trailing slash after a collection" do
    get '/trucks/', {}, env

    last_response.should be_ok
    response_json = JSON.parse last_response.body
    response_json.count.should > 0
  end

  it "returns the expected resource urls from the trucks collection" do
    get '/trucks', {}, env

    response_json = JSON.parse last_response.body
    p response_json
    response_json.detect { |e| e['href'] == '/trucks/4db0dedb387f7123c9000001'}.should_not be_nil
    response_json.detect { |e| e['href'] == '/trucks/4db0dedb387f7123c9000002'}.should_not be_nil
    response_json.detect { |e| e['href'] == '/trucks/smallblueone'}.should_not be_nil
  end

  it "returns the expected resource titles from the trucks collection" do
    get '/trucks', {}, env

    response_json = JSON.parse last_response.body
    response_json.detect { |e| e['title'] == '4db0dedb387f7123c9000001'}.should_not be_nil
    response_json.detect { |e| e['title'] == '4 wheeled truck'}.should_not be_nil
    response_json.detect { |e| e['title'] == 'smallblueone'}.should_not be_nil
  end

  it "excludes system indexes from root" do
    get '/', {}, env

    response_json = JSON.parse last_response.body
    response_json.detect { |e| e == '/system.indexes'}.should be_nil
  end

  it "returns a resource for a valid url" do
    get '/trucks/4db0dedb387f7123c9000001', {}, env
    last_response.should be_ok
  end

  it "fetches resource by ref when present" do
    get '/trucks/smallblueone', {}, env
    last_response.should be_ok
  end


  it "returns the expected resource for a valid url" do
    get '/trucks/4db0dedb387f7123c9000001', {}, env

    last_response.should be_ok

    response_json = JSON.parse last_response.body
    response_json['size'].should == 'big'
    response_json['colour'].should == 'green'
  end

  it "returns the id as the ref when not specifically set" do
    get '/trucks/4db0dedb387f7123c9000001', {}, env

    last_response.should be_ok

    response_json = JSON.parse last_response.body
    response_json['alias'].should == '4db0dedb387f7123c9000001'
  end

  it "returns the ref, not the id, when specifically set" do
    get '/trucks/4db0dedb387f7123c9000008', {}, env

    last_response.should be_ok

    response_json = JSON.parse last_response.body
    response_json['alias'].should == 'smallblueone'
  end

  it "strips the id from returned resources" do
    get '/trucks/4db0dedb387f7123c9000001', {}, env

    response_json = JSON.parse last_response.body
    response_json['_id'].should be_nil
  end

  it "invokes the jsonp callback" do
    get '/trucks/4db0dedb387f7123c9000001?callback=functionA', {}, env
    last_response.body.should include('functionA(')
  end


  it "returns a 404 for a non-existant resource url" do
    get '/trucks/4db0dedb387f7123c9000007', {}, env
    last_response.should_not == 200
  end

  it "returns not modified for an unchanged resource url" do
    header 'Content-Type', 'application/json;charset=utf-8'
    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27 }.to_json
    post '/bikes/', bike, env

    header 'If-Modified-Since', Time.now.httpdate.to_s
    get last_response.location, {}, env

#    last_response.status.should == 304
  end

  it "clients request no cache, then no cache returned" do
    header 'Cache-Control', 'no-cache'
    get '/', {}, env

    last_response['Cache-Control'].should == 'no-cache'
  end

  it "can be requested to restrict the number of results" do
    get URI.encode('/trucks?take=2'), {}, env

    response_json = JSON.parse last_response.body
    response_json.length.should == 2
  end


  it "can be requested to skip results" do
    get '/trucks?skip=2', {}, env

    response_json = JSON.parse last_response.body
    response_json.length.should == 1
    response_json.detect { |e| e['title'] == 'smallblueone'}.should_not be_nil
  end

  it "can be requested to skip and take results" do
    get '/trucks?skip=1&take=1', {}, env

    response_json = JSON.parse last_response.body
    response_json.length.should == 1
    response_json.detect { |e| e['title'] == '4 wheeled truck'}.should_not be_nil
  end

end