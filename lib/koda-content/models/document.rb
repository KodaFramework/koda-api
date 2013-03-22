require 'mongoid'

module Koda
  class Document
    include Mongoid::Document

    field :url
    field :name
    field :type
    field :data, type: Hash

    class << self
      def for(url)
        document = Koda::Document.new
        document.url = url
        document.type = File.dirname url
        document.name = File.basename url
        document.data = {}
        document
      end
    end
  end
end