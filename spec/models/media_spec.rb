require 'spec_helper'
require 'koda-content/models/media'

describe Koda::Media do
  describe "store" do
    it "picks a storage provider" do
      url = '/cars/porsche.jpg'
      expected_storage_info = {provider: :test_storage_provider, location: '/fake/'+url}
      class TestStorageProvider
        def put(file, url)
          # TODO this is really irrelevant for this test..
          {provider: :test_storage_provider, location: '/fake/'+url}
        end
      end
      Koda::Media.provider = TestStorageProvider
      storage_info = Koda::Media.put(StringIO.new, url)
      storage_info.should == expected_storage_info
    end
  end
end