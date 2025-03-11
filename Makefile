include .env

ruby-verify:
	find . -name "*.rb" -exec ruby -c {} \;

test:
	rspec -I lib spec/

fetch_all_posts:
	BEARER_AUTH_TOKEN=$(BEARER_AUTH_TOKEN) CONTEXT_ID=$(CONTEXT_ID) EXECUTOR_PUBLIC_KEY=$(EXECUTOR_PUBLIC_KEY) ruby examples/onlypeers_get_all_posts.rb
