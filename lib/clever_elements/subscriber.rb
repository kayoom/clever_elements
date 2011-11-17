require 'active_support/core_ext/hash/keys'
require 'clever_elements/model'

module CleverElements
  class Subscriber < Model
    class << self
      def all list_id = CleverElements::List.default_id
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
      
      def all_unsubscribed list_id = CleverElements::List.default_id
        response = proxy.get_subscriber_unsubscribes :listID => list_id
        
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
      def instantiate attributes, list_id = CleverElements::List.default_id
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
      @list_id ||= CleverElements::List.default_id
    end
    
    def list
      @list ||= list_id && CleverElements::List.find(list_id)
    end
    
    def create
      create_with :add_subscriber
    end
    
    def create_doi
      create_with :add_subscriber_doi
    end
    
    def destroy
      response = proxy.delete_subscriber :subscriberIDListShort => { :item => { :subscriberID => id }}
      
      if response == '200'
        true
      else
        false
      end
    rescue Savon::SOAP::Fault
      false
    end
    
    def unsubscribe
      return false unless list_id
      
      unsubscribe_from list_id
    end
    
    def unsubscribe_from list_or_id
      raise 'FIXME, this should work, but it doesnt, im guessing api broken' 
      list_id = if CleverElements::List === list_or_id
        list_or_id.id
      else
        list_or_id
      end
      
      response = proxy.unsubscribe_subscriber_from_list :subscriberIDList => { :item => { :subscriberID => id, :listID => list_id}}
      
      if response == '200'
        @list = @list_id = nil if @list_id == list_id
        true
      else
        false
      end
    rescue Savon::SOAP::Fault
      false
    end
    
    def unsubscribe_from_all
      response = proxy.unsubscribe_subscriber_from_all :subscriberIDList => { :item => { :subscriberID => id }}
      
      if response == '200'
        true
      else
        false
      end
    rescue Savon::SOAP::Fault
      false
    end
    
    protected
    def create_with method
      return true if id
      
      attributes = subscriber_attributes
      return false unless attributes[:listID] && attributes[:email]
      
      response = proxy.send method, :subscriber_list => {
        :item => attributes
      }
      
      # FIXME: it should return 200, but i get a Hash, have to interpret that as success...
      if response.is_a?(Hash)
        @id = self.class.all(list_id).last.id
        true
      end
    rescue Savon::SOAP::Fault
      false
    end
    
    def subscriber_attributes
      {
        :listID => list_id,
        :email => email,
        :customFields => { :item => [] }
      }
    end
  end
end