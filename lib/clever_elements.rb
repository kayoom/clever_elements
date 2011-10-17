require 'savon'

module CleverElements
  Client = Savon::Client.new do
    wsdl.document = "http://api.sendcockpit.com/server.php?wsdl"
  end
end