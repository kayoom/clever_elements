require 'spec_helper'

describe CleverElements::List do
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
  
  describe '.ids' do
    it 'should return an array of ids, if single result' do
      proxy.stub!(:get_list).and_return :item => { :list_id => 123 }
      
      CleverElements::List.ids.should == [123]
    end
    
    it 'should return an array of ids, if multiple results' do
      proxy.stub!(:get_list).and_return :item => [{ :list_id => 123 }, { :list_id => 456 }]
      
      CleverElements::List.ids.should == [123, 456]
    end
    
    it 'should return an empty array, if there are no lists' do
      proxy.stub!(:get_list) do
        raise fault
      end
      
      CleverElements::List.ids.should == []
    end
  end
  
  describe '.find' do
    it 'should return a List instance' do
      proxy.should_receive(:get_list_details).with(:listID => 123).and_return :list_id => 123, :list_name => 'abc'
      
      list = CleverElements::List.find 123
      list.should be_a CleverElements::List
      list.id.should == 123
      list.name.should == 'abc'
    end
    
    it 'should return nil if there is no list' do
      proxy.stub!(:get_list_details).and_return :list_id => nil
      
      list = CleverElements::List.find 123
      list.should be_nil
    end
  end
  
  describe '#initialize' do
    it 'should assign attributes' do
      list = CleverElements::List.new :name => 'abc', 'id' => 123, :description => { :a => :b}
      
      list.name.should == 'abc'
      list.id.should == 123
      list.description.should == ''
    end
  end
  
  describe '#create' do
    it 'should create a list with instance attributes and return true' do
      proxy.should_receive(:add_list).with(:list_name => 'abc', :list_description => 'def').and_return '200'
      
      list = CleverElements::List.new :name => 'abc', :description => 'def'
      list.create.should be true
    end
    
    it 'should return false if unsuccessful' do
      proxy.stub!(:add_list) do
        raise fault
      end
      
      list = CleverElements::List.new :description => 'def'
      list.create.should be false
    end
  end
  
  describe '#destroy' do
    it 'should destroy the list and set the id in the instance to nil' do
      proxy.should_receive(:delete_list).with(:listID => 123).and_return '200'
      
      list = CleverElements::List.new :id => 123, :name => 'abc'
      list.destroy.should be true
      list.id.should be_nil
    end
    
    it 'should return false if unsuccessful' do
      proxy.stub!(:delete_list) do
        raise fault
      end
      
      list = CleverElements::List.new :id => 123, :name => 'abc'
      list.destroy.should be false
    end
  end
end