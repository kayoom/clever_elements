require 'wasabi'
require 'active_support/concern'

Wasabi::Parser.class_eval do
  attr_reader :port_type, :type_restrictions
  
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
  end
  
  def parse_type_restrictions
    restrictions = @document.xpath "s0:definitions/s0:types/xs:schema/xs:complexType[@name]/xs:complexContent/xs:restriction", wsdl_ns
    
    @type_restrictions = {}
    restrictions.each do |restriction|
      base = restriction.attribute('base').to_s
      type = restriction.parent.parent
      type_name = type.attribute('name').to_s
      
      type_restriction = @type_restrictions[type_name] ||= {}
      type_restriction[base] = Hash[*restriction.at_xpath('xs:attribute', wsdl_ns).to_a]
    end
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
  end
  
  alias_method :parse_without_port_type, :parse
  def parse
    parse_without_port_type
    parse_port_type
    parse_type_restrictions
  end
  
  protected
  def wsdl_ns
    {"s0" => "http://schemas.xmlsoap.org/wsdl/", "xs" => "http://www.w3.org/2001/XMLSchema"}
  end
end