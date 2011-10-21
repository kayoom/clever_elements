require 'active_support/core_ext/hash/keys'
require 'clever_elements/model'

module CleverElements
  class List < Model
    class << self
      def find id
        response = proxy.get_list_details :listID => id
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
      
      self.id, self.name, self.description, self.subscriber, self.unsubscriber = attributes.values_at :id, :name, :description, :subscriber, :unsubscriber
    end
    
    def description= description
      if description.is_a? String
        @description = description
      else
        @description = ""
      end
    end
    
    def create
      response = proxy.add_list list_attributes
      
      if response == '200'
        true
      end
    rescue Savon::SOAP::Fault
      false
    end
    
    def destroy
      response = proxy.delete_list :listID => id
      
      if response == '200'
        @id = nil
        true
      else
        false
      end    
    rescue Savon::SOAP::Fault
      false
    end
    
    protected
    def list_attributes
      {
        :list_name => name,
        :list_description => description
      }
    end
  end
end