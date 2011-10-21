require 'active_support/core_ext/hash/keys'
require 'clever_elements/model'

module CleverElements
  class Subscriber < Model
    class << self
      def all list_id
        response = proxy.get_subscriber :listID => list_id
        
        ids = if Array === response[:item]
          response[:item].map do |subscriber_response|
            instantiate subscriber_response
          end
        elsif Hash === response[:item]
          [instantiate(response[:item])]
        else
          []
        end
      rescue Savon::SOAP::Fault
        []
      end
      
      protected
      def instantiate attributes
        attributes = {
          :id => attributes[:subscriber_id],
          :email => attributes[:subscriber_email]
        }
        
        new attributes
      end
    end
    
    attr_accessor :id, :email
    
    def initialize attributes = {}
      @id, @email = attributes.symbolize_keys.values_at(:id, :email)
    end
  end
end