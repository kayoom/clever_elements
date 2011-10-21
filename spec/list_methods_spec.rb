require 'spec_helper'

describe CleverElements::Proxy do
  let :client do
    CleverElements::Client.new '12345', 'xyz'
  end
  
  subject do
    client.proxy
  end
  
  describe '#get_list' do
    it 'request with a single result' do
      savon.expects(:api_get_list).returns(:simple)
    
      response = subject.get_list
      response[:item].should be_a Hash
      response[:item][:list_id].should == '54321'
    end
    
    it 'for a request with multiple results' do
      savon.expects(:api_get_list).returns(:multiple)
    
      response = subject.get_list
      response[:item].should be_an Array
      response[:item].count.should == 2
    end
  end
  
  describe '#get_list_details' do
    it 'if list_id exists, returns a Hash with list details for a specified list_id' do
      savon.expects(:api_get_list_details).returns(:simple)
      
      response = subject.get_list_details
      response.should be_a Hash
      response[:list_id].should == '54321'
    end
    
    it 'if list_id is omitted, raises an error' do
      savon.expects(:api_get_list_details).returns(:missing_parameter)
      
      proc { subject.get_list_details }.should raise_error Savon::SOAP::Fault
    end
    
    it 'if list_id doesnt exist, returns an empty hash' do
      savon.expects(:api_get_list_details).returns(:list_id_not_found)
      
      response = subject.get_list_details(:list_id => '54333')
      response.should be_a Hash
      response[:list_id].should be_nil
    end
  end
  
  describe '#add_list' do
    it 'returns status 200 on success' do
      savon.expects(:api_add_list).returns(:success)
      
      response = subject.add_list :list_name => 'neue liste'
      response.should == "200"
    end
    
    it 'raises an error on fault' do
      savon.expects(:api_add_list).returns(:fault)
      
      proc { subject.add_list }.should raise_error Savon::SOAP::Fault
    end
  end
  
  describe '#delete_list' do
    it 'returns status 200 on success' do
      savon.expects(:api_delete_list).returns(:success)
      
      response = subject.delete_list :list_id => 54322
      response.should == "200"
    end
    
    it 'raises an error on fault' do
      savon.expects(:api_delete_list).returns(:fault)
      
      proc { subject.delete_list }.should raise_error Savon::SOAP::Fault
    end
  end
  
  describe '#get_subscriber' do
    it 'raises error if list does not exist' do
      savon.expects(:api_get_subscriber).returns(:empty)
      
      proc { subject.get_subscriber }.should raise_error Savon::SOAP::Fault
    end
    
    it 'returns a hash if single result' do
      savon.expects(:api_get_subscriber).returns(:success)
      
      response = subject.get_subscriber :list_id => '54321'
      response[:item].should be_a Hash
      response[:item][:subscriber_email].should == 'max@muster.net'
    end
    
    it 'returns an array if multiple results' do
      savon.expects(:api_get_subscriber).returns(:multiple)
      
      response = subject.get_subscriber :list_id => '54322'
      response[:item].should be_an Array
      response[:item].count.should == 2
    end
  end
  
  describe '#get_subscriber_details' do
    it 'raises error if list does not exist' do
      savon.expects(:api_get_subscriber_details).returns(:fault)
      
      proc { subject.get_subscriber_details }.should raise_error Savon::SOAP::Fault
    end
    
    it 'returns a hash if single result' do
      savon.expects(:api_get_subscriber_details).returns(:success)
      
      response = subject.get_subscriber_details :list_id => '54321'
      response[:item].should be_a Hash
      response[:item][:subscriber_email].should == 'max@muster.net'
    end
    
    it 'returns an array if multiple results' do
      savon.expects(:api_get_subscriber_details).returns(:multiple)
      
      response = subject.get_subscriber_details :list_id => '54322'
      response[:item].should be_an Array
      response[:item].count.should == 2
    end
  end
  
  describe '#get_subscriber_unsubscribes' do
    it 'raises error if list does not exist' do
      savon.expects(:api_get_subscriber_unsubscribes).returns(:fault)
      
      proc { subject.get_subscriber_unsubscribes }.should raise_error Savon::SOAP::Fault
    end
    
    it 'returns a hash if single result' do
      savon.expects(:api_get_subscriber_unsubscribes).returns(:success)
      
      response = subject.get_subscriber_unsubscribes :list_id => '54321'
      response[:item].should be_a Hash
      response[:item][:subscriber_email].should == 'max@muster.net'
    end
    
    it 'returns an array if multiple results' do
      savon.expects(:api_get_subscriber_unsubscribes).returns(:multiple)
      
      response = subject.get_subscriber_unsubscribes :list_id => '54322'
      response[:item].should be_an Array
      response[:item].count.should == 2
    end
  end
end