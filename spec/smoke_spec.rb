# This is free and unencumbered software released into the public domain.

require 'calimero'

RSpec.describe Calimero do
  describe '.rpc_url' do
    it 'checks default RPC URL' do
      puts Calimero.default_rpc_url
    end
  end

  describe '.types' do
    it 'checks types definitions' do
      a = ""
      puts RpcRequestId.valid?(a)
      b = 1
      puts RpcRequestId.valid?(b)
    end
  end
end
