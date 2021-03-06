require 'spec_helper'
require 'koda-api/models/document'

describe "document" do
  describe "url" do
    it "sets the url of the document" do
      doc = Koda::Document.for '/cars/porsche'
      doc.uri.should == '/cars/porsche'
    end
  end
  describe "type" do
    it "document type is the first part of the url" do
      doc = Koda::Document.for '/cars/porsche'
      doc.type.should == '/cars'
    end

    it "can have a type that is multiple levels deep" do
      doc = Koda::Document.for '/cars/fast/racing/mclaren'
      doc.type.should == '/cars/fast/racing'
    end
  end

  describe "file_name" do
    it "gets the alias from the last part of the url" do
      doc = Koda::Document.for '/cars/porsche.json'
      doc.file_name.should == 'porsche.json'
    end
  end

  describe "url_name" do
    it "gets the url_name from the last part of the url" do
      doc = Koda::Document.for '/cars/porsche.json'
      doc.url_name.should == 'porsche'
    end
  end
end