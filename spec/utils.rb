# This is free and unencumbered software released into the public domain.

require 'calimero'

# Sample Base58-encoded keypair (taken and base58-encoded from libp2p-identity/keypair at
# https://github.com/libp2p/rust-libp2p/blob/88f7875ad1a3e240aa2d9b9fb6f6c5354f1a62eb/identity/src/keypair.rs#L826)

class Utils
  REF_BASE58_ED25519_KEYPAIR = '23jhTd4prPeF6nkLJw8pzLotwyvUD8jmU1SHCoz9m54pw5bHiyU1GihabX1wkeTXoNxTzAmjDjeJmAMAcTeDg8MpUV9o3'.freeze

  def self.valid_toml
    Tempfile.new('valid_config.toml').tap do |f|
      f.write(<<~TOML_FILE)
      [identity]
      keypair = "#{REF_BASE58_ED25519_KEYPAIR}"

      [server]
      listen = [
        "/ip4/127.0.0.1/tcp/2428",
        "/ip6/::1/tcp/2428",
      ]

      [sync]
      timeout_ms = 30000
      interval_ms = 30000
      TOML_FILE
      f.rewind
    end
  end

  def self.invalid_toml
    Tempfile.new('invalid_config.toml').tap do |f|
      f.write("invalid = syntax = here")
      f.rewind
    end
  end
end
