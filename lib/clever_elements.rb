require 'extensions/wasabi_parser'
require 'savon'

if defined?(Rails)
  require 'clever_elements/railtie'
end

require 'clever_elements/client'
require 'clever_elements/proxy'

module CleverElements
end