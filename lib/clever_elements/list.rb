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
      
      def all
        ids.map do |id|
          find(id)
        end
      end
      
      def first
        first_id = ids.first
        
        first_id && find(first_id)
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
      return true if id
      
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
      
      @subscriber ||= CleverElements::Subscriber.all(id).tap do |s|
        s.each do |subscriber|
          assign_list_to_subscriber subscriber
        end
      end
    end
    
    def build_subscriber attributes = {}
      CleverElements::Subscriber.new(attributes.merge(:list_id => id)).tap do |subscriber|
        assign_list_to_subscriber subscriber
      end
    end
    
    def create_subscriber attributes = {}
      subscriber = build_subscriber attributes
      
      if subscriber.create
        subscriber
      else
        false
      end
    end
    
    def create_subscriber_doi attributes = {}
      subscriber = build_subscriber attributes
      
      if subscriber.create_doi
        subscriber
      else
        false
      end
    end
    
    protected
    def assign_list_to_subscriber subscriber
      subscriber.instance_variable_set "@list", self
    end
    
    def list_attributes
      {
        :list_name => name,
        :list_description => description
      }
    end
  end
end