require 'tmpdir'
require 'spec_helper'
require 'koda-content/media_storage/file_system'

describe Koda::MediaStorage::FileSystem do
  let (:test_media_file) { File.join(File.dirname(__FILE__), '../media/test_media.gif') }
  describe 'put' do
    before do
      Koda::MediaStorage::FileSystem.root_folder = Dir.mktmpdir
    end
    class TempFile
      def initialize(path)
        @path = path
      end
      attr_accessor :path
    end

    it 'saves media to disc' do
      storage = Koda::MediaStorage::FileSystem.new

      url = '/logos/test_media.gif'
      expected_file = File.join(storage.class.root_folder, url)
      media_data = storage.put({tempfile: TempFile.new(test_media_file)}, url)
      File.should exist(expected_file)
      media_data['location'].should == expected_file
    end

    it 'sets the content type of the file' do
      storage = Koda::MediaStorage::FileSystem.new

      url = '/logos/test_media.gif'
      media_data = storage.put({tempfile: TempFile.new(test_media_file), type: 'image/jpeg'}, url)
      media_data['content-type'].should == 'image/jpeg'
    end
  end

  describe 'get' do
    it 'gets saved media' do
      storage = Koda::MediaStorage::FileSystem.new
      response = storage.get('storage' => {'location' => test_media_file} )

      response.should be_a(File)
      response.path.should == test_media_file
    end
  end
end