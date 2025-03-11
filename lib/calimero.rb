# This is free and unencumbered software released into the public domain.

module Calimero; end

require_relative 'calimero/version'
require_relative 'calimero/types'
require_relative 'calimero/jsonrpc'

module Calimero
  ##
  # @return [Calimero::default_rpc_url]
  def self.default_rpc_url
    @rpc_url ||= "http://127.0.0.1:2428"
  end
end

