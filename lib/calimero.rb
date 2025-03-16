# This is free and unencumbered software released into the public domain.

module Calimero; end

require_relative 'calimero/config'
require_relative 'calimero/jsonrpc'
require_relative 'calimero/types'
require_relative 'calimero/version'

module Calimero
  ##
  # @return [Calimero::default_rpc_url]
  def self.default_rpc_url
    @rpc_url ||= "http://127.0.0.1:2428"
  end

  ##
  # @return [Calimero::default_config_path]
  def self.default_config_folder
    @config_path ||= "#{Dir.home}/.calimero"
  end

  ##
  # @return [Calimero::load_config]
  # Utility method to load config from TOML file
  def self.load_config(file_path)
    Config.new(file_path)
  end
end

