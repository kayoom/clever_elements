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
  
  describe '#get_list' do
    describe 'returns an Array of Hashes' do      
      it 'for a request with a single result' do
        savon.expects(:api_get_list).returns(:simple)
      
        response = subject.get_list
        response.should be_an Array
        response.count.should == 1
        response.first.should be_a Hash
        response.first[:list_id].should == '54321'
      end
      
      it 'for a request with multiple results' do
        savon.expects(:api_get_list).returns(:multiple)
      
        response = subject.get_list
        response.should be_an Array
        response.count.should == 2
      end
    end
  end
  
  describe '#get_list_details' do
    describe 'returns a Hash with list details for a specified list_id' do
      it 'if list_id exists' do
        savon.exists(:api_get_list_details).returns(:simple)
        
        response = subject.get_list_details
      end
    end
  end
end