require 'spec_helper'

describe CleverElements::Client do
  subject do
    described_class.new '12345', 'xzy'
  end
  
  it 'should dispatch requests to savon' do
    savon.expects(:api_get_list).returns :simple
    
    subject.request :api_get_list
  end
  
  it 'should put arguments in the request body' do
    savon.expects(:api_get_list).with(:id => 123).returns :simple
    
    subject.request :api_get_list, :id => 123
  end
  
  it 'should pass credentials in soap header' do
    savon.expects(:api_get_list).
          with_header(:validate => { :userid => '12345', :apikey => 'xzy', :version => '1.0', :mode => 'test'}).
          returns :simple
          
    subject.request :api_get_list
  end
  
  it 'should provide an endpoint proxy' do
    subject.proxy.should be_a CleverElements::Proxy
  end
end