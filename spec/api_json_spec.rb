require 'spec_helper'
require 'koda-api'

describe Koda::Api do
  include Rack::Test::Methods

  let(:app) { Koda::Api }

  describe 'get' do
    it 'gets a document' do
      expected_document = Koda::Document.for('/cars/porsche.json')
      document_data = {max_speed: '180mph'}
      expected_document.data = document_data
      Koda::Document.stub(:where).and_return([expected_document])

      get '/cars/porsche.json'

      last_response.status.should == 200
      JSON(last_response.body).to_json.should == document_data.to_json
    end

    it 'returns 404 when document does not exist' do
      uri = '/cars/none.json'
      Koda::Document.should_receive(:where).with(uri: uri).and_return([])

      get uri
      last_response.status.should == 404
    end

    it 'gets a collection' do
      expected_documents = [Koda::Document.for('/cars/porsche.json'), Koda::Document.for('/cars/ferrari.json')]
      expected_documents_data = expected_documents.map{|document|
        data = document.data.dup
        data[:url] = document.uri
        data
      }
      Koda::Document.stub(:where).with(type: '/cars').and_return(expected_documents)
      get '/cars'

      last_response.status.should == 200
      JSON(last_response.body).to_json.should == expected_documents_data.to_json
    end
  end


  describe 'put' do
    it 'creates a document' do
      uri = '/cars/bugatti.json'
      document_data = {max_speed: '250mph'}
      server_document = mock('document')
      Koda::Document.should_receive(:where).with(uri: uri).and_return([])
      Koda::Document.should_receive(:for).with(uri).and_return(server_document)
      server_document.should_receive(:data=).with(JSON(document_data.to_json))
      server_document.should_receive(:save)

      put uri, document_data.to_json
      last_response.status.should == 201
    end

    it 'updates a document' do
      document_data = {max_speed: '200mph'}
      uri = '/cars/ferrari.json'
      existing_document = Koda::Document.for(uri)
      existing_document.should_receive(:save)

      Koda::Document.should_receive(:where).with(uri: uri).and_return([existing_document])

      put uri, document_data.to_json
      last_response.status.should == 200
      existing_document.data.to_json.should == document_data.to_json
    end
  end

  describe 'delete' do
    it 'deletes a document' do
      uri = '/cars/ferrari.json'
      existing_document = Koda::Document.for(uri)
      existing_document.should_receive(:delete)

      Koda::Document.should_receive(:where).with(uri: uri).and_return([existing_document])

      delete uri
      last_response.status.should == 200
    end

    it 'returns 404 when document does not exist' do
      uri = '/cars/none.json'
      Koda::Document.should_receive(:where).with(uri: uri).and_return([])

      delete uri
      last_response.status.should == 404
    end
  end

  describe 'url' do
    describe 'relative to the root of the website' do
      before :each do
        @setup_documents = [Koda::Document.for('/cars/porsche.json'), Koda::Document.for('/cars/ferrari.json')]
        Koda::Document.stub(:where).with(type: '/cars').and_return(@setup_documents)
      end

      it 'website is mounted at root' do
        expected_urls = @setup_documents.map{|document| document.uri }
        get '/cars'
        actual_urls = JSON(last_response.body).map {|document| document['url']}
        actual_urls.should == expected_urls
      end

      it 'website is mounted in sub location' do
        expected_urls = @setup_documents.map{|document| '/api' + document.uri }
        get '/api/cars', {}, {script_name: '/api'}
        actual_urls = JSON(last_response.body).map {|document| document['url']}
        actual_urls.should == expected_urls
      end
    end
  end
end