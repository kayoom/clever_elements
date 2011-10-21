require 'spec_helper'

describe CleverElements::Proxy do
  let :client do
    CleverElements::Client.new '12345', 'xyz'
  end
  
  subject do
    client.proxy
  end
  
  describe 'sending requests' do 
    it { should respond_to 'get_list' }
  
    it 'should prepend api_ to method names' do
      savon.expects(:api_get_list).returns(:simple)
  
      subject.get_list
    end
  
    it 'should carry over arguments and wrap them in the right message' do
      savon.expects(:api_get_list_details).with(:ctListDetailsRequest => { :listID => 123}).returns(:simple)
    
      subject.get_list_details :listID => 123
    end
  end
end