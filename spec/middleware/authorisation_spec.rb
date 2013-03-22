require 'spec_helper'
require 'sinatra/base'
require 'koda-content/middleware/content-authorisation'
require 'koda-content/models/user'
require 'koda-content/models/document'

module Koda::AuthorisationSpec
  class AuthorisationTestApp < Sinatra::Base
    use Koda::Authorisation::Content
    get ('*') {status 200}
    put '/*access-control.json' do
    end
    put ('*') {status 200}
    delete ('*') {status 200}
  end
end

describe 'Koda access integration' do
  include Rack::Test::Methods

  before do
    @logged_in_user = {'koda_user' => Koda::User.new({is_admin: false, name: 'joey'})}
  end

  def app
    Koda::AuthorisationSpec::AuthorisationTestApp
  end

  def setup_acl(url, acl)
    acl_document = Koda::Document.for(url)
    acl_document.data = acl
    type = File.dirname url
    Koda::Document.stub(:where).with(type: type, name: 'access-control.json').and_return([acl_document])
  end

  it "denies a resource into an existing collection if not allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    access_control = {'get' => '*', 'put' => '-'}
    setup_acl '/bikes/access-control.json', access_control

    get '/bikes/access-control.json', {}, @logged_in_user
    last_response.status.should == 200

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27}.to_json
    put'/bikes/new-bike.json', bike

    last_response.status.should == 405
  end

  it "allows a resource into an existing collection if user allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    access_control = {'get' => '*', 'put' => 'joey'}
    setup_acl '/bikes/access-control.json', access_control

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27}.to_json
    put '/bikes/new-bike.json', bike, @logged_in_user

    last_response.status.should == 200
  end

  it "allows a resource into an existing collection if all users allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    access_control = {'get' => '*', 'put' => '*'}
    setup_acl '/bikes/access-control.json', access_control

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27}.to_json
    put '/bikes/new-bike.json', bike, @logged_in_user

    last_response.status.should == 200
  end

  it "denies updating a resource in an existing collection if not allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    put '/bikes/access-control.json', bike, @logged_in_user

    access_control = {'get' => '*', 'put' => '-'}
    setup_acl '/bikes/restricted.json', access_control

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    put '/bikes/restricted.json', bike

    last_response.status.should == 405
  end

  it "allows updating a resource in an existing collection if user allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    put '/bikes/allowed.json', bike, @logged_in_user

    access_control = {'get' => '*', 'put' => 'joey'}
    setup_acl '/bikes/access-control.json', access_control

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    put '/bikes/allowed.json', bike, @logged_in_user

    last_response.status.should == 200
  end

  it "allows updating a resource in an existing collection if all users allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    put '/bikes/allowed.json', bike, @logged_in_user

    access_control = {'get' => '*', 'put' => '*'}
    setup_acl '/bikes/access-control.json', access_control

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    put '/bikes/allowed.json', bike, @logged_in_user

    last_response.status.should == 200
  end

  it "denies deleting a resource from an existing collection if not allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    put '/bikes/restricted.json', bike, @logged_in_user

    access_control = {'get' => '*', 'delete' => '-'}
    setup_acl '/bikes/access-control.json', access_control

    delete '/bikes/restricted.json', bike

    last_response.status.should == 405
  end

  it "allows deleting a resource from an existing collection if user allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    put '/bikes/allowed.json', bike, @logged_in_user

    access_control = {'get' => '*', 'delete' => 'joey'}
    setup_acl '/bikes/access-control.json', access_control

    delete '/bikes/allowed.json', bike, @logged_in_user

    last_response.status.should == 200
  end

  it "allows deleting a resource from an existing collection if all users allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    put '/bikes/allowed.json', bike, @logged_in_user

    access_control = {'get' => '*', 'delete' => '*'}
    setup_acl '/bikes/access-control.json', access_control

    delete '/bikes/allowed.json', bike, @logged_in_user

    last_response.status.should == 200
  end

  it "denies viewing a resource from an existing collection if not allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    put '/bikes/restricted.json', bike, @logged_in_user

    access_control = {'get' => '-'}
    setup_acl '/bikes/access-control.json', access_control

    get '/bikes/restricted.json'

    last_response.status.should == 405
  end

  it "allows viewing a resource from an existing collection if user allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    put '/bikes/allowed.json', bike, @logged_in_user

    access_control = {'get' => 'joey'}
    setup_acl '/bikes/access-control.json', access_control

    get '/bikes/allowed.json', {}, @logged_in_user

    last_response.status.should == 200
  end

  it "allows viewing a resource from an existing collection if all users allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    put '/bikes/allowed.json', bike, @logged_in_user

    access_control = {'get' => '*'}
    setup_acl '/bikes/access-control.json', access_control

    get '/bikes/allowed.json', {}, @logged_in_user

    last_response.status.should == 200
  end

end