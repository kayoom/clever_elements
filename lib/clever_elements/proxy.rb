require 'active_support/basic_object'

module CleverElements
  class Proxy
    attr_reader :client, :wsdl, :proxy_methods, :response_methods
    
    def initialize client
      @client = client
      @wsdl = client.savon.wsdl
      @proxy_methods = Module.new
      @response_methods = Module.new
      
      build_proxy
    end
    
    protected
    def build_proxy
      wsdl.operations.each_pair do |name, vals|
        build_operation_proxy_for name
      end
      
      extend proxy_methods
      extend response_methods
    end
    
    # Builds a response processor for a SOAP action:
    # The response processor uses message and type information of the
    # wsdl to "un-nest" the soap response as far as possible,
    # e.g. if the soap response is
    #   :a => { 
    #     :b => { 
    #       :c => { 
    #         :d => 1, 
    #         :e => 2 
    #       }
    #     }
    #   }
    # the processor will return
    #   { :d => 1, :e => 2}
    # (first non-trivial nesting level)
    def build_response_processor_for name
      method_name = "process_response_for_#{name}"
      message_name, message = wsdl.parser.port_type[name][:output].first
      key, type = message.first
      types = wsdl.parser.types
      keys = [message_name.snakecase.to_sym, key.snakecase.to_sym]
      while type
        type = type.split(':').last
        typedef = types[type]
      
        if typedef
          _keys = (typedef.keys - [:namespace, :type])
          break unless _keys.length == 1
          key = _keys.first
          
          type = typedef[key][:type]
          keys << key.snakecase.to_sym
        else
          break
        end
      end
      
      response_methods.send :define_method, method_name do |body|
        keys.inject body do |b, key|
          b[key] if b
        end
      end
      
      method_name
    end
    
    def build_operation_proxy_for name
      method_name = name.to_s.sub /^api_/, ''
      input_message = wsdl.parser.port_type[name][:input].first
      
      response_processor_name = build_response_processor_for name
      
      proxy_methods.send :define_method, method_name do |*args|
        arguments = args.first
        
        if input_message
          arguments = { input_message.to_sym => arguments }
        end
        
        response = client.request name, arguments
        send response_processor_name, response.body
      end
    end
  end
end