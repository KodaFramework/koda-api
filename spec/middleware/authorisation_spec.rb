require 'bundler/setup'
require 'rack/test'
require 'sinatra/base'
require 'json'
require 'time'
require_relative '../fake-mongo'
require_relative '../../lib/koda-content/middleware/content-authorisation'

module Koda::AuthorisationSpec
  class AuthorisationExtension < Koda::Authorisation
    def db_wrapper
      MongoDbDouble.instance
    end
  end

  class AuthorisationTestApp < Sinatra::Base
    use AuthorisationExtension
    get '*' do
      status 200
    end
    post '*' do
      status 201
    end
    put '*' do
      status 200
    end
    delete '*' do
      status 200
    end
  end
end

class UserHash < ::Hash
  def method_missing(name, *args, &block)
    @values[name] if has_key? name
  end
end

describe 'Koda access integration' do
  include Rack::Test::Methods

  before do
    @logged_in_user = {'koda_user' => UserHash.new({'alias' => 'joey', 'isadmin' => false, 'isallowed' => true})}
  end

  def app
    Koda::AuthorisationSpec::AuthorisationTestApp
  end

  it "denies a resource into an existing collection if not allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    access_control = {'read_users' => '*', 'write_users' => '-', 'alias' => 'access-control'}.to_json
    post '/bikes', access_control, @logged_in_user
    last_response.status.should == 201

    get '/bikes/access-control', {}, @logged_in_user
    last_response.status.should == 200

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27}.to_json
    post '/bikes', bike

    last_response.status.should == 405
  end

  it "allows a resource into an existing collection if user allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    access_control = {'read_users' => '*', 'write_users' => 'joey', 'alias' => 'access-control'}.to_json
    post '/bikes', access_control, @logged_in_user

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27}.to_json
    post '/bikes', bike, @logged_in_user

    last_response.status.should == 201
  end

  it "allows a resource into an existing collection if all users allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    access_control = {'read_users' => '*', 'write_users' => '*', 'alias' => 'access-control'}.to_json
    post '/bikes', access_control, @logged_in_user

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27}.to_json
    post '/bikes', bike, @logged_in_user

    last_response.status.should == 201
  end

  it "denies updating a resource in an existing collection if not allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    post '/bikes', bike, @logged_in_user

    access_control = {'read_users' => '*', 'write_users' => '-', 'alias' => 'access-control'}.to_json
    post '/bikes', access_control, @logged_in_user

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    put '/bikes/expensivefastone', bike

    last_response.status.should == 405
  end

  it "allows updating a resource in an existing collection if user allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    post '/bikes', bike, @logged_in_user

    access_control = {'read_users' => '*', 'write_users' => 'joey', 'alias' => 'access-control'}.to_json
    post '/bikes', access_control, @logged_in_user

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    put '/bikes/expensivefastone', bike, @logged_in_user

    last_response.status.should == 200
  end

  it "allows updating a resource in an existing collection if all users allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    post '/bikes', bike, @logged_in_user

    access_control = {'read_users' => '*', 'write_users' => '*', 'alias' => 'access-control'}.to_json
    post '/bikes', access_control, @logged_in_user

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    put '/bikes/expensivefastone', bike, @logged_in_user

    last_response.status.should == 200
  end

  it "denies deleting a resource from an existing collection if not allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    post '/bikes', bike, @logged_in_user

    access_control = {'read_users' => '*', 'modify_users' => '-', 'alias' => 'access-control'}.to_json
    post '/bikes', access_control, @logged_in_user

    delete '/bikes/expensivefastone', bike

    last_response.status.should == 405
  end

  it "allows deleting a resource from an existing collection if user allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    post '/bikes', bike, @logged_in_user

    access_control = {'read_users' => '*', 'modify_users' => 'joey', 'alias' => 'access-control'}.to_json
    post '/bikes', access_control, @logged_in_user

    delete '/bikes/expensivefastone', bike, @logged_in_user

    last_response.status.should == 200
  end

  it "allows deleting a resource from an existing collection if all users allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    post '/bikes', bike, @logged_in_user

    access_control = {'read_users' => '*', 'modify_users' => '*', 'alias' => 'access-control'}.to_json
    post '/bikes', access_control, @logged_in_user

    delete '/bikes/expensivefastone', bike, @logged_in_user

    last_response.status.should == 200
  end

  it "denies viewing a resource from an existing collection if not allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    post '/bikes', bike, @logged_in_user

    access_control = {'read_users' => '-', 'alias' => 'access-control'}.to_json
    post '/bikes', access_control, @logged_in_user

    get '/bikes/expensivefastone'

    last_response.status.should == 405
  end

  it "allows viewing a resource from an existing collection if user allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    post '/bikes', bike, @logged_in_user

    access_control = {'read_users' => 'joey', 'alias' => 'access-control'}.to_json
    post '/bikes', access_control, @logged_in_user

    get '/bikes/expensivefastone', {}, @logged_in_user

    last_response.status.should == 200
  end

  it "allows viewing a resource from an existing collection if all users allowed by access-control" do
    header 'Content-Type', 'application/json;charset=utf-8'

    bike = {'cost' => 'expensive', 'speed' => 'fast', 'gears' => 27, 'alias' => 'expensivefastone'}.to_json
    post '/bikes', bike, @logged_in_user

    access_control = {'read_users' => '*', 'alias' => 'access-control'}.to_json
    post '/bikes', access_control, @logged_in_user

    get '/bikes/expensivefastone', {}, @logged_in_user

    last_response.status.should == 200
  end

end