require 'calimero'

describe JsonRpcClient do
  let(:base_url) { 'http://127.0.0.1:2428' }
  let(:path) { '/jsonrpc' }
  let(:client) { JsonRpcClient.new(base_url, path) }
  let(:params) { RpcQueryParams.new('context123', 'testMethod', { 'arg1' => 'value1' }, 'public_key') }
  let(:config) { RequestConfig.new(timeout: 1000, headers: {'Content-Type' => 'application/json'})}

  before do
    @http_mock = instance_double(Net::HTTP)
    allow(Net::HTTP).to receive(:new).and_return(@http_mock)
    allow(@http_mock).to receive(:use_ssl=)
    allow(@http_mock).to receive(:open_timeout=)
    allow(@http_mock).to receive(:read_timeout=)

    # Stub `get_random_request_id` method
    request_id = 12345
    allow(client).to receive(:get_random_request_id).and_return(request_id)
  end

  it 'handles a successful response with no result' do
    response_body = {
      'jsonrpc' => '2.0',
      'id' => client.send(:get_random_request_id),
    }
    mock_http_response(HTTPStatusCodes::HTTPOK, response_body)

    result = client.execute(params, config)

    expect(result.result).to be_nil
    expect(result.error).to be_nil
  end

  it 'sends a valid request and parses a successful response' do
    request_id = client.send(:get_random_request_id)
    response_body = {
      'jsonrpc' => '2.0',
      'id' => request_id,
      'result' => { 'output' => 'success' }
    }
    mock_http_response(HTTPStatusCodes::HTTPOK, response_body);

    result = client.execute(params, config)

    expect(result.result).to eq({ 'output' => 'success' })
    expect(result.error).to be_nil
  end

  it 'handles a mismatched request ID' do
    request_id = 12345
    mismatched_request_id = request_id + 1
    response_body = {
      'jsonrpc' => '2.0',
      'id' => mismatched_request_id,
      'result' => {
        'output' => 'success'
      }
    }
    mock_http_response(HTTPStatusCodes::HTTPOK, response_body);

    # Stub `get_random_request_id` to return the original request_id for the request
    allow(client).to receive(:get_random_request_id).and_return(request_id)

    result = client.execute(params, config)

    expect(result.result).to be_nil
    expect(result.error[:error][:name]).to eq('MissmatchedRequestIdError')
  end

  it 'handles a JSON RPC error response' do
    response_body = {
      'jsonrpc' => '2.0',
      'id' => client.send(:get_random_request_id),
      'error' => {
        'type' => 'TestError'
      }
    }
    mock_http_response(HTTPStatusCodes::HTTPOK, response_body);

    result = client.execute(params, config)

    expect(result.error[:error][:name]).to eq('TestError')
  end

  it 'handles a non-200 HTTP response' do
    response_body = {
      'jsonrpc' => '2.0',
      'id' => client.send(:get_random_request_id),
      'error' => {
        'type' => 'SomeBadRequestError',
        'data' => 'some msg'
      }
    }
    mock_http_response(HTTPStatusCodes::HTTPBadRequest, response_body);

    result = client.execute(params, config)
    expect(result.error[:code]).to eq(HTTPStatusCodes::HTTPBadRequest)
    expect(result.error[:error][:name]).to eq('InvalidRequestError')
  end

  it 'handles a response with invalid JSON' do
    # Mock response separately, so it won't be converted to json within `mock_http_response()` method
    response_mock = instance_double(Net::HTTPResponse, code: HTTPStatusCodes::HTTPOK.to_s, body: 'invalid json')
    allow(@http_mock).to receive(:post).and_return(response_mock)

    result = client.execute(params, config)

    expect(result.error[:error][:name]).to eq('InvalidJsonResponseError')
  end

  it 'handles a server error (500)' do
    response_body = {
      'jsonrpc' => '2.0',
      'id' => client.send(:get_random_request_id),
      'error' => {
        'code' => -32603,
        'message' => 'Internal error'
      }
    }
    mock_http_response(HTTPStatusCodes::HTTPInternalServerError, response_body)

    result = client.execute(params, config)

    expect(result.error[:error][:name]).to eq('InvalidRequestError')
    expect(result.error[:code]).to eq(HTTPStatusCodes::HTTPInternalServerError)
  end

  it 'handles a custom error response' do
    response_body = {
      'jsonrpc' => '2.0',
      'id' => client.send(:get_random_request_id),
      'error' => {
        'type' => 'CustomError',
        'data' => {
          'type' => 'NestedError',
          'data' => {
            'type' => 'SomeNestedErrorType',
            'message' => 'Something went wrong'
          }
        }
      }
    }
    mock_http_response(HTTPStatusCodes::HTTPOK, response_body)

    result = client.execute(params, config)

    expect(result.error[:error][:name]).to eq('CustomError')
    expect(result.error[:error][:cause][:info][:message]).to eq('SomeNestedErrorType')
  end

  it 'handles a timeout' do
    allow(@http_mock).to receive(:post).and_raise(Net::OpenTimeout)

    result = client.execute(params, config)

    expect(result.error[:error][:name]).to eq('UnknownServerError')
    expect(result.error[:error][:cause][:info][:message]).to eq('Net::OpenTimeout')
  end
end

def mock_http_response(code, body)
  response_class = Net::HTTPResponse::CODE_TO_OBJ[code.to_s]
  response_mock = response_class.new('1.1', code.to_s, Net::HTTPResponse::CODE_TO_OBJ[code.to_s].name)
  response_mock.instance_variable_set(:@body, body.to_json)
  allow(response_mock).to receive(:read_body).and_return(body.to_json)
  allow(@http_mock).to receive(:post).and_return(response_mock)
  response_mock
end
