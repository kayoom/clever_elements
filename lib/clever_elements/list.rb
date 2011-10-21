require 'active_support/core_ext/hash/keys'
require 'clever_elements/model'

module CleverElements
  class List < Model
    class << self
      def find id
        response = proxy.get_list_details :list_id => id
        return nil if response[:list_id].nil?
        
        attributes = {}
        response.each_pair do |key, val|
          key = key.to_s.sub(/^list_/, '').to_sym
          attributes[key] = val
        end
        
        new attributes
      end
      
      def ids
        response = proxy.get_list
        
        ids = if Array === response[:item]
          response[:item].map do |id_response|
            id_response[:list_id]
          end
        elsif Hash === response[:item]
          [response[:item][:list_id]]
        else
          []
        end
      rescue Savon::SOAP::Fault
        []
      end
    end
    
    attr_accessor :id, :name, :description, :subscriber, :unsubscriber
    
    def initialize attributes = {}
      attributes = attributes.symbolize_keys
      
      @id, @name, @description, @subscriber, @unsubscriber = attributes.values_at :id, :name, :description, :subscriber, :unsubscriber
    end
  end
end