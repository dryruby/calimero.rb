# This is free and unencumbered software released into the public domain.

require 'calimero'

RSpec.describe Calimero do
  describe '.rpc_url' do
    it 'checks default RPC URL' do
      expected_default_rpc_url = "http://127.0.0.1:2428"
      expect(Calimero.default_rpc_url).to eq(expected_default_rpc_url)
    end
  end

  describe '.types' do
    it 'checks types definitions' do
      a = ""
      expect(RpcRequestId.valid?(a)).to be true
      b = 1
      expect(RpcRequestId.valid?(b)).to be true
    end
  end
end
