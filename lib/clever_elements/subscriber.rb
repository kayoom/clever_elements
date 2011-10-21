require 'active_support/core_ext/hash/keys'
require 'clever_elements/model'

module CleverElements
  class Subscriber < Model
    class << self
      def all list_id
        response = proxy.get_subscriber :listID => list_id
        
        ids = if Array === response[:item]
          response[:item].map do |subscriber_response|
            instantiate subscriber_response, list_id
          end
        elsif Hash === response[:item]
          [instantiate(response[:item], list_id)]
        else
          []
        end
      rescue Savon::SOAP::Fault
        []
      end
      
      protected
      def instantiate attributes, list_id
        attributes = {
          :id => attributes[:subscriber_id],
          :email => attributes[:subscriber_email],
          :list_id => list_id
        }
        
        new attributes
      end
    end
    
    attr_accessor :id, :email, :list_id
    
    def initialize attributes = {}
      @id, @email, @list_id = attributes.symbolize_keys.values_at(:id, :email, :list_id)
    end
    
    def list
      @list ||= CleverElements::List.find list_id
    end
  end
end