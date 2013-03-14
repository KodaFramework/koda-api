#require File.join(File.dirname(__FILE__), %w[../lib/koda-content])
#require File.join(File.dirname(__FILE__), %w[mongo_server_shared])
#require File.join(File.dirname(__FILE__), %w[uniform_server_shared])
#
#require_relative './doubles/mongo_db_double'
#require_relative './doubles/mongo_grid_double'
#
#
#describe 'Mongo KodaRms Unit' do
#  include Rack::Test::Methods
#
#  before(:each) do
#  end
#
#  before do
#  end
#
#  def app
#    Koda::Api
#  end
#
#  let(:env) {
#    {
#        'koda_db' => MongoDbDouble.instance,
#        'koda_db_grid' => MongoGridDouble.instance
#    }
#  }
#  it_should_behave_like "Mongo KodaRms options interface"
#  it_should_behave_like "Mongo KodaRms read interface"
#  it_should_behave_like "Mongo KodaRms write interface"
#
#end
