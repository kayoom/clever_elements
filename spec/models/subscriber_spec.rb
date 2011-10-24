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
  
  describe '#destroy' do
    it 'should delete a subscriber' do
      proxy.should_receive(:delete_subscriber).with(:subscriberIDListShort => { :item => { :subscriberID => 123456 }}).and_return '200'
      
      subscriber = CleverElements::Subscriber.new :id => 123456
      subscriber.destroy.should be true
    end
    
    it 'should return false if deletion fails' do
      proxy.should_receive(:delete_subscriber).with(:subscriberIDListShort => { :item => { :subscriberID => 123456 }}) do
        raise fault
      end
      
      subscriber = CleverElements::Subscriber.new :id => 123456
      subscriber.destroy.should be false
    end
  end
  
  describe '#unsubscribe' do
    it 'should unsubscribe subscriber from current list' do
      proxy.should_receive(:unsubscribe_subscriber_from_list).
        with(:subscriberDeleteList => { :item => { :listID => 123, :subscriberID => 123456 }}).and_return '200'
        
      subscriber = CleverElements::Subscriber.new :id => 123456, :list_id => 123
      subscriber.unsubscribe.should be true
      subscriber.list.should be_nil
    end
    
    it 'should return false if there is no list_id' do
      subscriber = CleverElements::Subscriber.new :id => 123456
      subscriber.unsubscribe.should be false
    end
    
    it 'should return false if there is an error' do
      proxy.should_receive(:unsubscribe_subscriber_from_list).
        with(:subscriberDeleteList => { :item => { :listID => 123, :subscriberID => 123456 }}) do
        
        raise fault
      end
        
      subscriber = CleverElements::Subscriber.new :id => 123456, :list_id => 123
      subscriber.unsubscribe.should be false
    end
  end
  
  describe '#unsubscribe_from' do
    it 'should unsubscribe from a specific list' do
      proxy.should_receive(:unsubscribe_subscriber_from_list).
        with(:subscriberDeleteList => { :item => { :listID => 123, :subscriberID => 123456 }}).and_return '200'
      
      list = CleverElements::List.new :id => 123
      subscriber = CleverElements::Subscriber.new :id => 123456
      subscriber.unsubscribe_from(list).should be true
    end
    
    it 'should unsubscribe from a specified list_id' do
      proxy.should_receive(:unsubscribe_subscriber_from_list).
        with(:subscriberDeleteList => { :item => { :listID => 123, :subscriberID => 123456 }}).and_return '200'
      
      subscriber = CleverElements::Subscriber.new :id => 123456
      subscriber.unsubscribe_from(123).should be true
    end
  end
  
  describe '#create' do
    it 'should return false if list_id missing' do
      subscriber = CleverElements::Subscriber.new :email => 'max@muster.com'
      proc {subscriber.create}.should_not raise_error
    end
    
    it 'should do nothing if already has an id' do
      proxy.should_not_receive(:add_subscriber)
      
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
  
  describe '#create_doi' do
    it 'should return false if list_id missing' do
      subscriber = CleverElements::Subscriber.new :email => 'max@muster.com'
      proc {subscriber.create_doi}.should_not raise_error
    end
    
    it 'should do nothing if already has an id' do
      proxy.should_not_receive(:add_subscriber_doi)
      
      subscriber = CleverElements::Subscriber.new :email => 'max@muster.com', :list_id => 54321, :id => 123456
      subscriber.create_doi
    end
    
    it 'should add a subscriber to a list with double opt-in' do
      proxy.should_receive(:add_subscriber_doi).with(:subscriber_list => { 
        :item => {
          :listID => '54321',
          :email => 'max@muster.com',
          :customFields => { :item => [] }
        }
      }).and_return '200'
      
      proxy.should_receive(:get_subscriber).with(:listID => "54321").and_return(:item => { :subscriber_id => 123456})
      
      subscriber = CleverElements::Subscriber.new :email => 'max@muster.com', :list_id => "54321"
      subscriber.create_doi.should be true
      subscriber.id.should == 123456
    end
  end
end