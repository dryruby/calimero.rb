# This is free and unencumbered software released into the public domain.

require_relative 'context'
require_relative 'rpc_request'

class RpcError < StandardError
  attr_reader :id, :jsonrpc, :code, :error_info

  def initialize(id, jsonrpc, code, error_info)
    @id = id
    @jsonrpc = jsonrpc
    @code = code
    @error_info = error_info
    super(error_info[:message])
  end
end

class RpcErrorInfo < StandardError
  attr_reader :name, :cause

  def initialize(name, cause)
    @name = name
    @cause = cause
    super(cause[:message])
  end
end

class RpcCauseInfo < StandardError
  attr_reader :name, :info

  def initialize(name, info)
    @name = name
    @info = info
    super(info[:message])
  end
end

class RpcClient
  def execute(params, config = {})
    raise NotImplementedError, "Subclasses must implement execute"
  end
end

class RequestConfig
  attr_accessor :timeout, :headers

  def initialize(timeout: nil, headers: nil)
    @timeout = timeout
    @headers = headers
  end

  def to_h
    {
      timeout: @timeout,
      headers: @headers
    }
  end
end

class RpcResult
  attr_accessor :result, :error

  def initialize(result: nil, error: nil)
    @result = result
    @error = error
  end

  def to_h
    {
      result: @result,
      error: @error,
    }
  end
end

class RpcQueryParams
  attr_accessor :contextId, :method, :argsJson, :executorPublicKey

  def initialize(contextId, method, argsJson, executorPublicKey)
    @contextId = contextId
    @method = method
    @argsJson = argsJson
    @executorPublicKey = executorPublicKey
  end

  def to_h
    {
      contextId: @contextId,
      method: @method,
      argsJson: @argsJson,
      executorPublicKey: @executorPublicKey
    }
  end
end

class RpcQueryResponse
  attr_accessor :output

  def initialize(output: nil)
    @output = output
  end
end
