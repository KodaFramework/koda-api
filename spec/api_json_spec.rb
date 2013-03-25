require 'spec_helper'
require 'koda-content'

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
      url = '/cars/none.json'
      Koda::Document.should_receive(:where).with(url: url).and_return([])

      get url
      last_response.status.should == 404
    end

    it 'gets a collection' do
      expected_documents = [Koda::Document.for('/cars/porsche.json'), Koda::Document.for('/cars/ferrari.json')]
      expected_documents_data = expected_documents.map{|document|
        data = document.data.dup
        data[:url] = document.url
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
      url = '/cars/bugatti.json'
      document_data = {max_speed: '250mph'}
      server_document = mock('document')
      Koda::Document.should_receive(:where).with(url: url).and_return([])
      Koda::Document.should_receive(:for).with(url).and_return(server_document)
      server_document.should_receive(:data=).with(JSON(document_data.to_json))
      server_document.should_receive(:save)

      put url, document_data.to_json
      last_response.status.should == 201
    end

    it 'updates a document' do
      document_data = {max_speed: '200mph'}
      url = '/cars/ferrari.json'
      existing_document = Koda::Document.for(url)
      existing_document.should_receive(:save)

      Koda::Document.should_receive(:where).with(url: url).and_return([existing_document])

      put url, document_data.to_json
      last_response.status.should == 200
      existing_document.data.to_json.should == document_data.to_json
    end
  end

  describe 'delete' do
    it 'deletes a document' do
      url = '/cars/ferrari.json'
      existing_document = Koda::Document.for(url)
      existing_document.should_receive(:delete)

      Koda::Document.should_receive(:where).with(url: url).and_return([existing_document])

      delete url
      last_response.status.should == 200
    end

    it 'returns 404 when document does not exist' do
      url = '/cars/none.json'
      Koda::Document.should_receive(:where).with(url: url).and_return([])

      delete url
      last_response.status.should == 404
    end
  end
end