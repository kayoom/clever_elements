module CleverElements
  class Client
    attr_reader :savon
    
    def initialize user_id, api_key, mode = 'test'
      @savon = Savon::Client.new "http://api.sendcockpit.com/server.php?wsdl"
    end
    
    def request method, arguments = {}
      savon.request method do
        soap.body = arguments
      end
    end
  end
end