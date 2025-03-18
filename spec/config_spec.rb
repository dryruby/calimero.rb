# This is free and unencumbered software released into the public domain.

require 'calimero'
require 'tempfile'

require_relative 'utils'

RSpec.describe Config do
  describe '#initialize' do
    context 'with a valid TOML file' do
      let(:config) { Config.new(Utils.valid_toml.path) }

      it 'initializes with a Ed25519Keypair instance' do
        expect(config.keypair).to be_a(Ed25519Keypair)
      end

      it 'allows hash-like access to TOML fields' do
        expect(config['sync']['timeout_ms']).to eq(30000)
      end

      it 'allows dynamic method access to TOML fields' do
        expect(config.sync).to eq({ 'timeout_ms' => 30000, 'interval_ms' => 30000 })
        expect(config.identity).to eq({ 'keypair' => Utils::REF_BASE58_ED25519_KEYPAIR })
      end
    end

    context 'with a missing TOML file' do
      it 'raises a ConfigError' do
        nonexistent_path = '/nonexistent/path'
        expect { Config.new(nonexistent_path) }.to raise_error(ConfigError, "Config file '#{nonexistent_path}' not found")
      end
    end

    context 'with an invalid TOML file' do
      it 'raises a ConfigError' do
        expect { Config.new(Utils.invalid_toml.path) }.to raise_error(ConfigError, /Failed to parse TOML file/)
      end
    end

    context 'with a TOML file missing keypair' do
      let(:no_keypair_toml) do
        Tempfile.new('no_keypair_config.toml').tap do |f|
          f.write("[identity]\npeer_id = \"some_value\"")
          f.rewind
        end
      end

      it 'raises a ConfigError' do
        expect { Config.new(no_keypair_toml.path) }
          .to raise_error(ConfigError, "'keypair' not found in [identity] section")
      end
    end
  end
end
