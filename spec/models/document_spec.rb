require 'spec_helper'
require 'koda-content/models/document'

describe "document" do
  describe "url" do
    it "sets the url of the document" do
      doc = Koda::Document.for '/cars/porsche'
      doc.url.should == '/cars/porsche'
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

  describe "alias" do
    it "gets the alias from the last part of the url" do
      doc = Koda::Document.for '/cars/porsche'
      doc.name.should == 'porsche'
    end
  end

  #describe "access_control" do
  #  it "is nil when nothing specified" do
  #    doc = Document.new url: '/cars/porsche'
  #    doc.access_control.should be_nil
  #  end
  #end
end