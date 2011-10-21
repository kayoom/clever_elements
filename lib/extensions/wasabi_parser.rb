require 'wasabi'
require 'active_support/concern'

# This is a rather bad monkeypatch extending Wasabi to read message definitions from the wsdl file.
Wasabi::Parser.class_eval do
  attr_reader :port_type
  
  def parse_port_type
    operations = @document.xpath "s0:definitions/s0:portType/s0:operation", wsdl_ns

    @port_type = {}
    operations.each do |operation|
      name = operation.attribute('name').to_s
      key = name.snakecase.to_sym
      
      hash = @port_type[key] = {}
      
      if input = operation.at_xpath('s0:input', wsdl_ns)
        message_name = input.attribute('message').to_s.split(':').last
        input_message_parts = @document.xpath %Q{s0:definitions/s0:message[@name="#{message_name}"]/s0:part/@name}, wsdl_ns
        
        hash[:input] = input_message_parts.map &:to_s
      end
      
      if output = operation.at_xpath('s0:output', wsdl_ns)
        message_name = output.attribute('message').to_s.split(':').last
        output_message_parts = @document.xpath %Q{s0:definitions/s0:message[@name="#{message_name}"]/s0:part}, wsdl_ns
        
        message = {}.tap do |output|
          output_message_parts.each do |part|
            name = part.attribute('name').to_s
            type = part.attribute('type').to_s
            
            output[name] = type
          end
        end
        
        hash[:output] = { message_name => message }
      end
    end
  rescue
    # Don't break Wasabi with bad monkeypatching
  end
  
  alias_method :process_type_without_all, :process_type  
  def process_type(type, name)
    process_type_without_all type, name
    return unless type
    
    @types[name] ||= { :namespace => find_namespace(type) }

    type.xpath("./xs:all/xs:element",
      "xs" => "http://www.w3.org/2001/XMLSchema"
    ).each do |inner_element|
      @types[name][inner_element.attribute('name').to_s] = {
        :type => inner_element.attribute('type').to_s
      }
    end
  rescue
    # Don't break Wasabi with bad monkeypatching
  end
  
  alias_method :parse_without_port_type, :parse
  def parse
    parse_without_port_type
    parse_port_type
  end
  
  protected
  def wsdl_ns
    {"s0" => "http://schemas.xmlsoap.org/wsdl/", "xs" => "http://www.w3.org/2001/XMLSchema"}
  end
end