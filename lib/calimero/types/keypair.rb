# This is free and unencumbered software released into the public domain.

require 'base58'
require 'ed25519'

class KeypairError < StandardError; end

class Ed25519Keypair
  attr_reader :private_key, :public_key, :stored_public_key

  # Initialize with a Base58-encoded keypair string
  def initialize(base58_keypair)
    raise KeypairError, "Base58 keypair cannot be nil" if base58_keypair.nil?
    @key_bytes = decode_base58(base58_keypair)
    validate_keypair_length
    extract_keys
    initialize_signing_key
  end

  # Sign a message (as raw bytes)
  def sign(message)
    @signing_key.sign(message)
  end

  # Verify a signature against a message
  def verify(signature, message)
    @verify_key.verify(signature, message)
    true
  rescue Ed25519::VerifyError
    false
  end

  def decode_base58(base58_keypair)
    Base58.base58_to_binary(base58_keypair, :bitcoin)
  rescue StandardError => e
    raise KeypairError, "Failed to decode Base58 keypair: #{e.message}"
  end

  def validate_keypair_length
    return if @key_bytes.length == 68
    raise KeypairError, "Unexpected keypair length: #{@key_bytes.length} bytes (expected 68)"
  end

  def extract_keys
    @private_key = @key_bytes[4..35]  # 32-byte private key
    @stored_public_key = @key_bytes[36..67]  # 32-byte stored public key
    unless @private_key.length == 32 && @stored_public_key.length == 32
      raise KeypairError, "Invalid key lengths: private #{@private_key.length}, stored public #{@stored_public_key.length} (expected 32 each)"
    end
  end

  def initialize_signing_key
    @signing_key = Ed25519::SigningKey.new(@private_key)
    @verify_key = @signing_key.verify_key
    @public_key = @verify_key.to_bytes
  rescue ArgumentError => e
    raise KeypairError, "Invalid Ed25519 private key: #{e.message}"
  end

  private :decode_base58, :validate_keypair_length, :extract_keys, :initialize_signing_key
end
