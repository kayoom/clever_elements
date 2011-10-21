require 'spec_helper'

describe CleverElements::Subscriber do
  let :client do
    CleverElements::Client.new '12345', 'xyz'
  end
  
  let :proxy do
    client.proxy
  end
  
  before do
    CleverElements::Model.proxy = proxy
  end
  
  let :fault do
    http = stub :body => ''
    
    Savon::SOAP::Fault.new http
  end
  
  describe '.all' do
    it 'should return an Array of subscriber for a listID for a single result' do
      proxy.should_receive(:get_subscriber).with(:listID => 123).and_return(
        :item => { :subscriber_id => 123123, :email => 'max@muster.de' }
      )
      
      subscriber = CleverElements::Subscriber.all 123
      subscriber.should be_an Array
      subscriber.first.should be_a CleverElements::Subscriber
      subscriber.first.list_id.should == 123
    end
    
    it 'should return an Array of subscriber for a listID for multiple results' do
      proxy.should_receive(:get_subscriber).with(:listID => 123).and_return(
        :item => [{ :subscriber_id => 123123, :email => 'max@muster.de' }, { :subscriber_id => 456456, :email => 'mux@master.de' }]
      )
      
      subscriber = CleverElements::Subscriber.all 123
      subscriber.should be_an Array
      subscriber.count.should == 2
    end
    
    it 'should return [] if list id not found' do
      proxy.stub!(:get_subscriber) do
        raise fault
      end
      
      CleverElements::Subscriber.all(123).should == []
    end
  end
  
end