require 'spec_helper'
require 'koda-api'

describe Koda::Api do
  include Rack::Test::Methods

  let(:app) { Koda::Api }
  let (:test_media_file) { File.join(File.dirname(__FILE__), 'media/test_media.gif') }

  describe 'get' do
    it 'gets a stored media object' do
      expected_document = Koda::Document.for('/cars/porsche.jpg')
      document_data = {'storage' => {'content-type' => 'image/jpeg'}}
      expected_document.data = document_data
      Koda::Document.stub(:where).and_return([expected_document])

      expected_response = 'pretend this is some image data'
      Koda::Media.should_receive(:get).with(document_data).and_return(StringIO.new(expected_response))

      get '/cars/porsche.jpg'

      last_response['content-type'].should == 'image/jpeg'
      last_response.status.should == 200
      last_response.body.should == expected_response
    end
  end

  describe 'put' do
    it 'creates a media object' do
      uri = '/cars/bugatti.gif'
      storage_info = {provider: :test, location: '/fake'}
      media_document = mock('media_document')
      Koda::Media.should_receive(:put).with(anything(), uri).and_return(storage_info)
      Koda::Document.should_receive(:where).with(uri: uri).and_return([])
      Koda::Document.should_receive(:for).with(uri).and_return(media_document)
      media_document.should_receive(:data=).with(storage: storage_info)
      media_document.should_receive(:save)

      put uri, media: Rack::Test::UploadedFile.new(test_media_file, 'image/gif')
      last_response.status.should == 201
    end
  end
end