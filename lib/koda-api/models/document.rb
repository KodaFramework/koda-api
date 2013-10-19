require 'mongoid'

module Koda
  class Document
    include Mongoid::Document

    attr_accessor :url

    field :uri
    field :file_name
    field :type
    field :data, type: Hash

    def url_name
      File.basename file_name, ".*"
    end

    class << self
      def for(uri)
        document = Koda::Document.new
        document.uri = uri
        document.type = File.dirname uri
        document.file_name = File.basename uri
        document.data = {}
        document
      end
    end
  end
end