#require_relative '../lib/koda-content'
#require_relative 'mongo_server_shared'
#require_relative 'uniform_server_shared'
#require_relative 'testdata/mongo_test_data'
#
#describe 'Mongo KodaRms Integration' do
#  include Rack::Test::Methods
#
#  def clear_database database
#    dont_delete = ['fs.chunks']
#    database.collections.each do |collection|
#      begin
#        collection.drop if not dont_delete.include? collection.name
#      rescue
#        nil
#      end
#    end
#  end
#
#  def populate_database_with_documents database
#    MongoTestData.collections.each_pair do |collection_name, documents|
#      database.create_collection collection_name
#      documents.each do |document|
#        database[collection_name].save document
#      end
#    end
#  end
#
#  attr_reader :env
#
#  before(:each) do
#    database = Mongo::Connection.new('localhost', 27017).db('koda_test')
#    clear_database database
#    populate_database_with_documents database
#    @env = { 'koda_db' => database }
#  end
#
#
#  def app
#    Koda::Api
#  end
#
#  context = lambda{
#    let(:env) { env }
#  }
#
#
#  it_should_behave_like "Uniform Spoon interface", context
#  it_should_behave_like "Mongo KodaRms options interface", context
#  it_should_behave_like "Mongo KodaRms read interface", context
#  it_should_behave_like "Mongo KodaRms write interface", context
#
#end