# This is free and unencumbered software released into the public domain.

module RpcRequestId
  def self.valid?(value)
    value.is_a?(String) || value.is_a?(Numeric)
  end
end
