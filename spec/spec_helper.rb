require 'rubygems'
require 'bundler/setup'

require 'clever_elements'
require 'rspec/mocks'
require 'rspec/mocks/spec_methods'
require 'rspec/mocks/standalone'
require 'savon_spec'

Savon::Spec::Fixture.path = File.expand_path("../fixtures", __FILE__)

RSpec.configure do |config|
  config.include Savon::Spec::Macros
end

Savon.logger = HTTPI.logger = Logger.new(File.open('/dev/null', 'w'))
Savon::Spec::Mock.class_eval do
  def with_header(soap_header)
    Savon::SOAP::XML.any_instance.expects(:header=).with(soap_header) if mock_method == :expects
    self    
  end
end
