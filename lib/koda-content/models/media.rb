module Koda
  class Media
    class << self
      attr_accessor :provider
      def put(file, uri)
        storage_provider = provider.new
        storage_provider.put(file, uri)
      end

      def get(document_data)
        storage_provider = provider.new
        storage_provider.get(document_data)
      end
    end
  end
end