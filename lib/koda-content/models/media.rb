module Koda
  class Media
    class << self
      attr_accessor :provider
      def put(file, url)
        storage_provider = provider.new
        storage_provider.put(file, url)
      end

      def get(document_data)
        storage_provider = provider.new
        storage_provider.get(document_data)
      end
    end
  end
end