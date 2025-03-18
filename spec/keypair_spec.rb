# This is free and unencumbered software released into the public domain.

require 'calimero'
require 'base58'

require_relative 'utils'

RSpec.describe Ed25519Keypair do
  let(:config) { Config.new(Utils.valid_toml.path) }
  let(:keypair) { config.keypair }

  describe '#initialize' do
    it 'sets up keys from a valid Base58 keypair' do
      expect(keypair.private_key).to be_a(String)
      expect(keypair.public_key).to be_a(String)
      expect(keypair.stored_public_key).to be_a(String)
      expect(keypair.private_key.length).to eq(32)
      expect(keypair.public_key.length).to eq(32)
      expect(keypair.stored_public_key.length).to eq(32)
    end

    it 'raises a KeypairError for nil Base58' do
      expect { Ed25519Keypair.new(nil) }.to raise_error(KeypairError, 'Base58 keypair cannot be nil')
    end

    it 'raises a KeypairError for invalid Base58' do
      expect { Ed25519Keypair.new("invalid-base58") }.to raise_error(KeypairError, /Failed to decode Base58 keypair/)
    end
  end

  describe '#sign and #verify' do
    let(:message) { Time.now.utc.to_i.to_s }

    it 'signs and verifies a message successfully' do
      signature = keypair.sign(message)
      expect(signature.length).to eq(64)
      expect(keypair.verify(signature, message)).to be true
    end

    it 'fails verification with a tampered message' do
      signature = keypair.sign(message)
      expect(keypair.verify(signature, message + "123")).to be false
    end
  end

  describe 'protobuf decoding' do
    # Sample keypair taken from libp2p-identity/keypair at https://github.com/libp2p/rust-libp2p/blob/88f7875ad1a3e240aa2d9b9fb6f6c5354f1a62eb/identity/src/keypair.rs#L826)
    let(:expected_public_key_hex) { '1ed1e8fae2c4a144b8be8fd4b47bf3d3b34b871c3cacf6010f0e42d474fce27e' }

    it 'raises a KeypairError for incorrect protobuf prefix' do
      # Decode valid Base58 to binary
      valid_keypair_bytes = Base58.base58_to_binary(Utils::REF_BASE58_ED25519_KEYPAIR, :bitcoin)

      # Replace first 4 bytes with invalid prefix (e.g., 01020304)
      invalid_keypair_bytes = "\x01\x02\x03\x04" + valid_keypair_bytes[4..-1]

      # Re-encode to Base58
      invalid_base58_keypair = Base58.binary_to_base58(invalid_keypair_bytes, :bitcoin)
      # Verify with the manually constructed keypair with invalid protobuf bytes
      expect(invalid_base58_keypair).to eq('8eZocEJsWbqchRdvi4NfCwrye4XWq6AM9hSbnD8WMpZrCD8MoTuWCcbugKi2HnWr9GRBeBkFo7L2MrPBn1yS2SQz8Qsf')

      # Test keypair creation with the invalid protobuf prefix
      expect { Ed25519Keypair.new(invalid_base58_keypair) }.to raise_error(KeypairError, /Invalid protobuf prefix/)
    end

    it 'verifies the public key of the decoded keypair' do
      expect(keypair.stored_public_key.unpack1('H*').force_encoding('UTF-8')).to eq(expected_public_key_hex)
    end
  end

end

