require 'spec_helper'

describe CleverElements::Proxy do
  let :client do
    CleverElements::Client.new '12345', 'xyz'
  end
  
  subject do
    client.proxy
  end
  
  describe '#get_subscriber_history' do
    it 'raises error if subscriber does not exist' do
      savon.expects(:api_get_subscriber_history).returns(:empty)
      
      proc { subject.get_subscriber_history }.should raise_error Savon::SOAP::Fault
    end
    
    it 'returns an array' do
      pending
      savon.expects(:api_get_subscriber).returns(:success)
      
      response = subject.get_subscriber_history :subscriber_id => '69742892'
    end
  end
  
  describe '#api_add_subscriber' do
    it 'raises error if list does not exist' do
      savon.expects(:api_add_subscriber).returns(:fault)
      
      proc { subject.add_subscriber }.should raise_error Savon::SOAP::Fault
    end
    
    # it 'returns a hash if single result' do
    #   savon.expects(:api_get_subscriber_details).returns(:success)
    #   
    #   response = subject.get_subscriber_details :list_id => '54321'
    #   response[:item].should be_a Hash
    #   response[:item][:subscriber_email].should == 'max@muster.net'
    # end
    # 
    # it 'returns an array if multiple results' do
    #   savon.expects(:api_get_subscriber_details).returns(:multiple)
    #   
    #   response = subject.get_subscriber_details :list_id => '54322'
    #   response[:item].should be_an Array
    #   response[:item].count.should == 2
    # end
  end
  
  # describe '#get_subscriber_unsubscribes' do
  #   it 'raises error if list does not exist' do
  #     savon.expects(:api_get_subscriber_unsubscribes).returns(:fault)
  #     
  #     proc { subject.get_subscriber_unsubscribes }.should raise_error Savon::SOAP::Fault
  #   end
  #   
  #   it 'returns a hash if single result' do
  #     savon.expects(:api_get_subscriber_unsubscribes).returns(:success)
  #     
  #     response = subject.get_subscriber_unsubscribes :list_id => '54321'
  #     response[:item].should be_a Hash
  #     response[:item][:subscriber_email].should == 'max@muster.net'
  #   end
  #   
  #   it 'returns an array if multiple results' do
  #     savon.expects(:api_get_subscriber_unsubscribes).returns(:multiple)
  #     
  #     response = subject.get_subscriber_unsubscribes :list_id => '54322'
  #     response[:item].should be_an Array
  #     response[:item].count.should == 2
  #   end
  # end
end