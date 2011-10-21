require 'active_support/core_ext/hash/keys'
require 'clever_elements/model'

module CleverElements
  class List < Model
    class << self
      def find id
        response = proxy.get_list_details :listID => id
        return nil if response[:list_id].nil?
        
        description = response[:description]
        description = String === description ? description : ''
        attributes = {
          :id => response[:list_id],
          :name => response[:list_name],
          :description => description,
          :subscriber_count => response[:list_subscriber],
          :unsubscriber_count => response[:list_unsubscriber]
        }
        
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
    
    Attributes = [:id, :name, :description, :subscriber_count, :unsubscriber_count]
    attr_accessor *Attributes
    
    def initialize attributes = {}
      attributes = attributes.symbolize_keys
      
      Attributes.each do |attribute|
        instance_variable_set "@#{attribute}", attributes[attribute]
      end
    end
    
    def create
      response = proxy.add_list list_attributes
      
      if response == '200'
        @id = self.class.ids.last
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
    
    def subscriber
      return [] unless id
      
      @subscriber ||= CleverElements::Subscriber.all id
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