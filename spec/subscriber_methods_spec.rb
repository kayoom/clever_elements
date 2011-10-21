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
      savon.expects(:api_get_subscriber_history).returns(:fault)
      
      proc { subject.get_subscriber_history }.should raise_error Savon::SOAP::Fault
    end
    
    it 'returns an array' do
      pending
      savon.expects(:api_get_subscriber).returns(:success)
      
      response = subject.get_subscriber_history :subscriber_id => '69742892'
    end
  end
  
  describe '#add_subscriber' do
    it 'raises error if list does not exist' do
      savon.expects(:api_add_subscriber).returns(:fault)
      
      proc { subject.add_subscriber }.should raise_error Savon::SOAP::Fault
    end
    
    it 'returns a hash on success' do
      savon.expects(:api_add_subscriber).returns(:success)
      
      response = subject.add_subscriber(:subscriber_list => { 
        :item => {
          :listID => '54321',
          :email => 'max@muster.com',
          :customFields => { :item => []
          }
        }
      })
      
      response.should be_a Hash
    end
  end
  
  describe '#add_subscriber_doi' do
    it 'raises error if list does not exist' do
      savon.expects(:api_add_subscriber_doi).returns(:fault)
      
      proc { subject.add_subscriber_doi }.should raise_error Savon::SOAP::Fault
    end
    
    it 'returns a Hash on success' do
      savon.expects(:api_add_subscriber_doi).returns(:success)
      
      response = subject.add_subscriber_doi(:subscriber_list => { 
        :item => {
          :listID => '54321',
          :email => 'max@muster.com',
          :customFields => { :item => [] }
        }
      })
      
      response.should be_a Hash
    end
  end
  
  describe '#delete_subscriber' do
    it 'raises error if subscriber id is invalid' do
      savon.expects(:api_delete_subscriber).returns(:fault)
      
      proc { subject.delete_subscriber }.should raise_error Savon::SOAP::Fault
    end
    
    it 'returns 200 on success' do
      savon.expects(:api_delete_subscriber).returns(:success)
      
      response = subject.delete_subscriber :subscriber_id_list_short => { :item => { :subscriber_id => '123456789'}}
      response.should == '200'
    end
  end
  
  describe '#unsubscribe_subscriber_from_list' do
    it 'raises error if list id is invalid' do
      savon.expects(:api_unsubscribe_subscriber_from_list).returns(:fault)
      
      proc { subject.unsubscribe_subscriber_from_list }.should raise_error Savon::SOAP::Fault
    end
    
    it 'returns 200 on success' do
      savon.expects(:api_unsubscribe_subscriber_from_list).returns(:success)
      
      response = subject.unsubscribe_subscriber_from_list :subscriber_id_list => { :item => { :subscriber_id => '123456789', :list_id => 54321}}
      response.should == '200'
    end
  end
  
  describe '#unsubscribe_subscriber_from_all' do
    it 'raises error if subscriber id is invalid' do
      savon.expects(:api_unsubscribe_subscriber_from_all).returns(:fault)
      
      proc { subject.unsubscribe_subscriber_from_all }.should raise_error Savon::SOAP::Fault
    end
    
    it 'returns 200 on success' do
      savon.expects(:api_unsubscribe_subscriber_from_all).returns(:success)
      
      response = subject.unsubscribe_subscriber_from_all :subscriber_id_list => { :item => { :subscriber_id => '123456789'}}
      response.should == '200'
    end
  end
  
  describe '#get_subscriber_fields' do
    it 'raises error if there are no subscriber fields' do
      savon.expects(:api_get_subscriber_fields).returns(:fault)
      
      proc { subject.get_subscriber_fields }.should raise_error Savon::SOAP::Fault
    end
    
    it 'returns an array on success' do
      savon.expects(:api_get_subscriber_fields).returns(:success)
      
      response = subject.get_subscriber_fields
      response[:item].should be_an Array
    end
  end
  
  describe '#add_subscriber_field' do
    it 'raises error if type is omitted' do
      savon.expects(:api_add_subscriber_field).returns(:fault)
      
      proc { subject.add_subscriber_field }.should raise_error Savon::SOAP::Fault
    end
    
    it 'returns 200 on success' do
      savon.expects(:api_add_subscriber_field).returns(:success)
      
      response = subject.add_subscriber_field :custom_field_name => 'Anrede', :custom_field_type => 1
      response.should == '200'
    end
  end
  
  describe '#delete_subscriber_field' do
    it 'raises error if field id is omitted' do
      savon.expects(:api_delete_subscriber_field).returns(:fault)
      
      proc { subject.delete_subscriber_field }.should raise_error Savon::SOAP::Fault
    end
    
    it 'returns 200 on success' do
      savon.expects(:api_delete_subscriber_field).returns(:success)
      
      response = subject.delete_subscriber_field :customFieldID => '123456'
      response.should == '200'
    end
  end
end