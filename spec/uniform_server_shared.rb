require 'rack/test'
require 'json'
require 'time'

shared_examples_for "Uniform Spoon interface" do

  it "responds with a json list at the root" do
    get '/', {}, env
    
    last_response.should be_ok
    response_json = JSON.parse last_response.body
    response_json.count.should > 0
  end
  
  it "responds with a list of resource links at the root" do
    get '/', {}, env
    
    last_response.should be_ok
    response_json = JSON.parse last_response.body
    response_json.each {|e| e['href'].should_not be_nil}
  end
  
  it "responds with a list of gettable resource links from root" do
    get '/', {}, env
    
    last_response.should be_ok
    response_json = JSON.parse last_response.body
    response_json.each do |e| 
      get e['href'], {}, env
      last_response.should be_ok
    end
  end
  
  it "responds from the root with a list of resource links, all of which contain links that correctly respond recursively for all directories" do
    recursive_resource_requests '/'    
  end
  
  it "all resources with content type json should be parseable as json" do
    recursive_resource_requests '/', &method(:url_claiming_to_be_json_should_be)
  end
  
  it "all lists that support posts should be postable to with json" do
    recursive_resource_requests '/', &method(:url_supporting_post_should_create_resource_after_post)
  end
  
  it "all resources that support puts with json should replace resource" do
    recursive_resource_requests '/', &method(:url_supporting_put_of_json_should_alter_the_resource)
  end
  
  it "all resources that support puts of non-json should replace resource" do
    recursive_resource_requests '/', &method(:url_supporting_put_of_media_should_alter_the_resource)
  end
  
  it "all resources supporting delete should be deletable" do
    recursive_resource_requests '/', &method(:url_supporting_delete_should_remove_resource_after_delete)
  end

  
  def url_claiming_to_be_json_should_be url
    get url, {}, env
    
    content_type = last_response.content_type

    if (content_type != nil && last_response.content_type.include?('application/json'))
      response_json = JSON.parse last_response.body
      response_json.should_not be_nil
    end
  end
  
  def url_supporting_delete_should_remove_resource_after_delete url
    options url, {}, env
    
    if (last_response["ALLOW"].include?('DELETE'))
     delete url, {}, env
     get url, {}, env
     
     last_response.should_not be_found
    end
  end
  
  def url_supporting_post_should_create_resource_after_post url
    options url, {}, env
    
    if (last_response["ALLOW"].include?('POST'))
      post url, {"a field" => "a value"}.to_json
      get last_response.location, {}, env
                  
      response_json = JSON.parse last_response.body
      response_json['a field'].should == 'a value'
    end
  end
  
  def url_supporting_put_of_json_should_alter_the_resource url
    options url, {}, env
    
    if (last_response["ALLOW"].include?('PUT'))
      get url, {}, env
      
      if (last_response.content_type == 'application/json')
        old_resource = last_response.body
        old_resource_hash = JSON.parse old_resource  
        new_resource_hash = old_resource_hash
        new_resource_hash['unlikelytoalreadybeaproperty'] = 'a value'   
        put url, new_resource_hash.to_json
        last_response.location.should == url
        get url, {}, env
        fetched_resource_hash = JSON.parse last_response.body
        fetched_resource_hash.should == new_resource_hash
      end
    end
  end
  
  def url_supporting_put_of_media_should_alter_the_resource url
    options url, {}, env
    
    if (last_response["ALLOW"].include?('PUT'))
      get url, {}, env
      
      if !(last_response.content_type == 'application/json')        
        old_resource = last_response.body

        put url, old_resource
        last_response.location.should == url
        get url, {}, env
        
        las_response.body.should == old_resource
      end
    end
  end


  def recursive_resource_requests url, &block
    options url, {}, env

    if (last_response["ALLOW"].include?('GET') ) 
      get url, {}, env
      last_response.should be_ok
      
      if (last_response.content_type == 'application/json;kodameta=list')
        response_json = JSON.parse last_response.body
      
        response_json.each do |list_item|
          recursive_resource_requests list_item['href'], &block
        end    
            
      end

      block.call url if block != nil             
    end
    
  end 
   
end