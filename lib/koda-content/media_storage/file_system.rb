require 'fileutils'

module Koda
  module MediaStorage
    class FileSystem
      def put(file, url)
         source = file[:tempfile].path
         destination = File.join(self.class.root_folder, url)

         FileUtils.mkdir_p File.dirname destination
         FileUtils.cp source, destination
        {'provider' => 'filesystem', 'location' => destination, 'content-type' => file[:type]}
      end

      def get(media_data)
        source = media_data['storage']['location']
        File.open source, 'rb'
      end

      class << self
        attr_accessor :root_folder
      end
    end
  end
end