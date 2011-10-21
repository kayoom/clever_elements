require 'extensions/wasabi_parser'
require 'savon'

if defined?(Rails)
  require 'clever_elements/railtie'
end

require 'clever_elements/client'
require 'clever_elements/proxy'
require 'clever_elements/list'
# require 'clever_elements/list'

module CleverElements
end