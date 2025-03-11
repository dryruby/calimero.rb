require 'net/http'
require 'uri'
require 'json'

require_relative 'types/rpc'

module HTTPStatusCodes
  HTTPOK = 200
  HTTPBadRequest = 400
  HTTPInternalServerError = 500
end

class JsonRpcClient < RpcClient
  attr_reader :path, :base_url, :default_timeout

  def initialize(base_url, path, default_timeout = 1000)
    @base_url = base_url
    @path = path
    @default_timeout = default_timeout
  end

  def execute(params, config = RequestConfig.new(timeout: default_timeout))
    request('execute', params, config)
  end

  def request(method, params, config = RequestConfig.new(timeout: default_timeout))
    request_id = get_random_request_id
    data = {
      jsonrpc: '2.0',
      id: request_id,
      method: method,
      params: params.instance_variables.each_with_object({}) { |var, hash| hash[var.to_s.delete('@')] = params.instance_variable_get(var) }
    }

    uri = URI.parse("#{@base_url}#{@path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    http.open_timeout = config.timeout || @default_timeout
    http.read_timeout = config.timeout || @default_timeout
    headers = {'Content-Type' => 'application/json'}.merge(config.headers ? config.headers : {})

    begin
      response = http.post(uri.path, data.to_json, headers)
      parsed_response = JSON.parse(response.body)

      if response.is_a?(Net::HTTPOK)
        if parsed_response['id'] != request_id
          return RpcResult.new(result: nil, error: {
            code: HTTPStatusCodes::HTTPBadRequest,
            id: parsed_response['id'],
            jsonrpc: parsed_response['jsonrpc'],
            error: {
              name: 'MissmatchedRequestIdError',
              cause: {
                name: 'MissmatchedRequestIdError',
                info: {
                  message: "Missmatched RequestId expected #{request_id}, got #{parsed_response['id']}"
                }
              }
            }
          })
        end

        error_data = parsed_response['error']
        #TODO figure out if there are still weird use cases where error_data['data']['data'] might not be a Hash, but a String
        if error_data
          error_cause_name = if error_data['data'].is_a?(Hash)
                               error_data.dig('data', 'type')
                             else
                               error_data['type']
                             end
          error_message = if error_data['data'].is_a?(Hash) && error_data['data']['data'].is_a?(Hash)
                            error_data.dig('data', 'data', 'type')
                          else
                            error_data['data']
                          end
          return RpcResult.new(result: nil, error: {
            code: HTTPStatusCodes::HTTPBadRequest,
            id: parsed_response['id'],
            jsonrpc: parsed_response['jsonrpc'],
            error: {
              name: error_data['type'],
              cause: {
                name: error_cause_name,
                info: {
                  message: error_message
                }
              }
            }
          })
        end

        return RpcResult.new(result: parsed_response['result'], error: nil)
      else
        error_data = parsed_response['error']
        error_message = if error_data['data'].is_a?(Hash) && error_data['data']['data'].is_a?(Hash)
                          error_data.dig('data', 'data', 'type')
                        else
                          error_data['data']
                        end
        return RpcResult.new(result: nil, error: {
          id: parsed_response['id'],
          jsonrpc: parsed_response['jsonrpc'],
          code: response.code.to_i,
          error: {
            name: 'InvalidRequestError',
            cause: {
              name: 'InvalidRequestError',
              info: {
                message: error_message
              }
            }
          }
        })
      end
    rescue JSON::ParserError
      return RpcResult.new(result: nil, error: {
        id: request_id,
        jsonrpc: '2.0',
        code: HTTPStatusCodes::HTTPInternalServerError,
        error: {
          name: 'InvalidJsonResponseError',
          cause: {
            name: 'InvalidJsonResponseError',
            info: {
              message: "Invalid JSON response from server."
            }
          }
        }
      })
    rescue StandardError => e
      return RpcResult.new(result: nil, error: {
        id: request_id,
        jsonrpc: '2.0',
        code: HTTPStatusCodes::HTTPInternalServerError,
        error: {
          name: 'UnknownServerError',
          cause: {
            name: 'UnknownServerError',
            info: {
              message: e.message
            }
          }
        }
      })
    end
  end

  def get_random_request_id
    rand(2**32)
  end

  private :request, :get_random_request_id
end
