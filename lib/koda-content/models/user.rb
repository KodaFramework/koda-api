require 'mongoid'

module Koda
  class User
    include Mongoid::Document

    field :name
    field :provider
    field :provider_uid

    class << self
      def make(options)
        user = User.new
        user.name = options[:name]
        user.provider = options[:provider]
        user.provider_uid = options[:uid]
        user.save
        user
      end

      def create_or_load(options)
        user = User.where(:provider => options[:provider], :uid => options[:uid]).first
        user = make(options) if user.nil?
        user
      end

    end
  end
end