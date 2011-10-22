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
  
  describe '.all_unsubscribed' do
    it 'should return an Array of unsubscriber for a listID for a single result' do
      proxy.should_receive(:get_subscriber_unsubscribes).with(:listID => 123).and_return(
        :item => { :subscriber_id => 123123, :email => 'max@muster.de' }
      )
      
      subscriber = CleverElements::Subscriber.all_unsubscribed 123
      subscriber.should be_an Array
      subscriber.first.should be_a CleverElements::Subscriber
      subscriber.first.list_id.should == 123
    end
    
    it 'should return an Array of unsubscriber for a listID for multiple results' do
      proxy.should_receive(:get_subscriber_unsubscribes).with(:listID => 123).and_return(
        :item => [{ :subscriber_id => 123123, :email => 'max@muster.de' }, { :subscriber_id => 456456, :email => 'mux@master.de' }]
      )
      
      subscriber = CleverElements::Subscriber.all_unsubscribed 123
      subscriber.should be_an Array
      subscriber.count.should == 2
    end
    
    it 'should return [] if list id not found' do
      proxy.stub!(:get_subscriber_unsubscribes) do
        raise fault
      end
      
      CleverElements::Subscriber.all(123).should == []
    end
  end
  
  describe '#create' do
    it 'do nothing if already has an id' do
      proxy.should_not_receive(:add_list)
      
      subscriber = CleverElements::Subscriber.new :email => 'max@muster.com', :list_id => 54321, :id => 123456
      subscriber.create
    end
    
    it 'should add a subscriber to a list' do
      proxy.should_receive(:add_subscriber).with(:subscriber_list => { 
        :item => {
          :listID => '54321',
          :email => 'max@muster.com',
          :customFields => { :item => [] }
        }
      }).and_return '200'
      
      proxy.should_receive(:get_subscriber).with(:listID => "54321").and_return(:item => { :subscriber_id => 123456})
      
      subscriber = CleverElements::Subscriber.new :email => 'max@muster.com', :list_id => "54321"
      subscriber.create.should be true
      subscriber.id.should == 123456
    end
  end
end