module CleverElements
  class Client
    API_VERSION = "1.0"
    
    attr_reader :savon, :user_id, :api_key, :mode
    
    def initialize user_id, api_key, mode = 'test'
      @savon = Savon::Client.new "http://api.sendcockpit.com/server.php?wsdl"
      @user_id, @api_key, @mode = user_id, api_key, mode
    end
    
    def request method, arguments = {}
      savon.request method do
        soap.body = arguments
        soap.header = authentication_header
      end
    end
    
    def authentication_header
      {
        :validate => {
          :userid => user_id,
          :apikey => api_key,
          :version => API_VERSION,
          :mode => mode
        }
      }
    end
    
    def proxy
      @proxy ||= Proxy.new self
    end
  end
end