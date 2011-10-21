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
        raise Savon::SOAP::Fault.new('no list')
      end
      
      CleverElements::List.ids.should == []
    end
  end
  
  describe '.find' do
    it 'should return a List instance' do
      proxy.stub!(:get_list_details).with(:list_id => 123).and_return :list_id => 123, :list_name => 'abc'
      
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
      list = CleverElements::List.new :name => 'abc', 'id' => 123
      
      list.name.should == 'abc'
      list.id.should == 123
    end
  end
end