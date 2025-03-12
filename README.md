# Calimero Network for Ruby

[![License](https://img.shields.io/badge/license-Public%20Domain-blue.svg)](https://unlicense.org)
[![Compatibility](https://img.shields.io/badge/ruby-3.0%2B-blue)](https://rubygems.org/gems/calimero)
[![Package](https://img.shields.io/gem/v/calimero)](https://rubygems.org/gems/calimero)
[![Documentation](https://img.shields.io/badge/rubydoc-latest-blue)](https://rubydoc.info/gems/calimero)

**Calimero.rb** is a [Ruby] client library for the [Calimero Network].

> [!TIP]
> 🚧 _We are building in public. This is presently under heavy construction._

## ✨ Features

- Implemented natively in Ruby with minimal dependencies, ensuring low overhead and efficient performance.
- Implements a `JsonRpcClient` for sending queries and updates to the applications in Calimero nodes.
- Handles write and read calls to Calimero network applications.
- 🚧 Manages authentication workflows, including token acquisitions and refresh.
- 🚧Implements a `WsSubscriptionsClient` for subscribing to real-time updates from the Calimero nodes.
- 🚧 Supports interaction with Calimero Admin and Calimero Node APIs.
- 🚧 Handles config management of Calimero nodes.
- Adheres to the Ruby API Guidelines in its [naming conventions].
- 100% free and unencumbered public domain software.

## 🛠️ Prerequisites

- [Ruby] 3.0+

## ⬇️ Installation

### Installation via RubyGems

```bash
gem install calimero
```

## 👉 Examples

### Importing the library

```ruby
require 'calimero'
```

### Executing arbitrary method in Calimero Application

```ruby
client = JsonRpcClient.new('http://localhost:2428', '/jsonrpc')
params = RpcQueryParams.new('your_application_context_id', 'some_method', { 'some': 'args' }, 'executor_public_key')
bearer_auth_token = "some bearer auth token"
headers = {
  'Content-Type' => 'application/json',
  'Authorization' => "Bearer #{bearer_auth_token}"
}
request_config = RequestConfig.new(timeout: 1000, headers: headers)
result = client.execute(params, request_config)
if result.error
  puts "Error: #{result.error}"
else
  puts "Result: #{result.result}"
end
```

### Fetching all posts from OnlyPeers application

You can query all the posts in the given [OnlyPeers] demo application, by using the following example:
```sh
CONTEXT_ID=<ONLYPEERS_CONTEXT_ID> EXECUTOR_PUBLIC_KEY=<YOUR_EXECUTOR_PUBLIC_KEY> BEARER_AUTH_TOKEN=<YOUR_BEARER_AUTH_TOKEN> ruby examples/onlypeers_get_all_posts.rb
```

## 📚 Reference

https://rubydoc.info/gems/calimero

## 👨‍💻 Development

```bash
git clone https://github.com/dryruby/calimero.rb.git
```

- - -

[![Share on Twitter](https://img.shields.io/badge/share%20on-twitter-03A9F4?logo=twitter)](https://x.com/share?url=https://github.com/dryruby/calimero.rb&text=calimero.rb)
[![Share on Reddit](https://img.shields.io/badge/share%20on-reddit-red?logo=reddit)](https://reddit.com/submit?url=https://github.com/dryruby/calimero.rb&title=calimero.rb)
[![Share on Hacker News](https://img.shields.io/badge/share%20on-hacker%20news-orange?logo=ycombinator)](https://news.ycombinator.com/submitlink?u=https://github.com/dryruby/calimero.rb&t=calimero.rb)
[![Share on Facebook](https://img.shields.io/badge/share%20on-facebook-1976D2?logo=facebook)](https://www.facebook.com/sharer/sharer.php?u=https://github.com/dryruby/calimero.rb)

[Calimero Network]: https://calimero.network/
[Ruby]: https://ruby-lang.org
[OnlyPeers]: https://calimero-network.github.io/tutorials/awesome-projects/only-peers/
