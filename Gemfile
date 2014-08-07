
source 'https://rubygems.org/'

gemspec

# this is for travis-ci
gem 'rest-core', :path => 'rest-core' if
  File.exist?("#{File.dirname(File.expand_path(__FILE__))}/rest-core/Gemfile")

gem 'rake'
gem 'pork'
gem 'muack'
gem 'webmock'

gem 'json'
gem 'json_pure'
gem 'multi_json'

gem 'rack'

platforms :ruby do
  gem 'yajl-ruby'
end

platforms :rbx do
  gem 'rubysl-weakref'    # used in rest-core
  gem 'rubysl-singleton'  # used in rake
  gem 'rubysl-rexml'      # used in crack used in webmock
  gem 'rubysl-bigdecimal' # used in crack used in webmock
  gem 'rubysl-test-unit'  # used in activesupport
  gem 'rubysl-enumerator' # used in activesupport
  gem 'rubysl-benchmark'  # used in activesupport
  gem 'racc'              # used in journey used in actionpack
end

platforms :jruby do
  gem 'jruby-openssl'
end
