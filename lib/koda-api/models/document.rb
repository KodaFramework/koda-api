require 'mongoid'

module Koda
  class Document
    include Mongoid::Document

    field :uri
    field :name
    field :type
    field :data, type: Hash

    def alias
      File.basename name, ".*"
    end

    class << self
      def for(uri)
        document = Koda::Document.new
        document.uri = uri
        document.type = File.dirname uri
        document.name = File.basename uri
        document.data = {}
        document
      end
    end
  end
end