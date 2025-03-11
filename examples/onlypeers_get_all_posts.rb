#!/usr/bin/env ruby -Ilib -I../lib
require 'calimero'

trap(:SIGINT) { abort '' }

def only_peers_get_all_posts
  context_id = get_required_env('CONTEXT_ID')
  puts "Context id: #{context_id}"
  executor_public_key = get_required_env('EXECUTOR_PUBLIC_KEY')
  puts "Executor public key: #{executor_public_key}"
  bearer_auth_token = get_required_env('BEARER_AUTH_TOKEN')
  puts "Bearer token: \"Bearer #{bearer_auth_token}\""

  method_name = 'posts'
  argsJson = {'feedRequest': {}}
  headers = {
    'Content-Type' => 'application/json',
    'Authorization' => "Bearer #{bearer_auth_token}"
  }

  node_url = ENV['RPC_URL'] || Calimero.default_rpc_url
  jsonrpc_path = '/jsonrpc'
  client = JsonRpcClient.new(node_url, jsonrpc_path)
  puts "Initialized Calimero JSON RPC Client with URL: #{node_url}#{jsonrpc_path}"

  query_params = RpcQueryParams.new(context_id, method_name, argsJson, executor_public_key)
  request_config = RequestConfig.new(timeout: 1000, headers: headers)
  result = client.execute(query_params, request_config)

  if ENV['VERBOSE'] && ENV['VERBOSE'].to_i == 1
    p result
  end

  if result.result
    puts result.result
  else
    puts result.error
  end
end

def get_required_env(key)
  begin
    ENV.fetch(key)
  rescue KeyError
    raise "Environment variable #{key} is not set."
  end
end

only_peers_get_all_posts

