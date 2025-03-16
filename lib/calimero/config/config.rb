# This is free and unencumbered software released into the public domain.

require 'toml-rb'
require_relative '../types/keypair'

class ConfigError < StandardError; end

# Configuration class that holds a Keypair and is extensible for future for other fields
class Config
  attr_reader :keypair

  # Initialize with a TOML file path
  def initialize(file_path)
    @config_data = load_toml(file_path)
    @keypair = Ed25519Keypair.new(@config_data.dig('identity', 'keypair'))
  end

  # Extend config with additional fields in the future
  def method_missing(method_name, *args, &block)
    if @config_data.key?(method_name.to_s)
      @config_data[method_name.to_s]
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    @config_data.key?(method_name.to_s) || super
  end

  def load_toml(file_path)
    TomlRB.load_file(file_path)
  rescue Errno::ENOENT
    raise ConfigError, "Config file '#{file_path}' not found"
  rescue TomlRB::ParseError => e
    raise ConfigError, "Failed to parse TOML file: #{e.message}"
  end

  private :load_toml
end

