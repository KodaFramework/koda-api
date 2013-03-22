require 'spec_helper'
require 'koda-content/models/user'

describe 'user' do
  describe 'creates a new user' do

    it 'adds original authentication properties' do
      user = Koda::User.create provider: 'twithub', uid: '1234', name: 'joe bloggs'
      user.name.should == 'joe bloggs'
      user.provider.should == 'twithub'
      user.provider_uid.should == '1234'
    end

  end
end