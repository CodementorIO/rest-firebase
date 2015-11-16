# rest-firebase [![Build Status](https://secure.travis-ci.org/CodementorIO/rest-firebase.png?branch=master)](http://travis-ci.org/CodementorIO/rest-firebase) [![Coverage Status](https://coveralls.io/repos/CodementorIO/rest-firebase/badge.png)](https://coveralls.io/r/CodementorIO/rest-firebase) [![Join the chat at https://gitter.im/CodementorIO/rest-firebase](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/CodementorIO/rest-firebase)

by [Codementor][]

[Codementor]: https://www.codementor.io/

## LINKS:

* [github](https://github.com/CodementorIO/rest-firebase)
* [rubygems](https://rubygems.org/gems/rest-firebase)
* [rdoc](http://rdoc.info/projects/CodementorIO/rest-firebase)

## DESCRIPTION:

Ruby Firebase REST API client built on top of [rest-core][].

[rest-core]: https://github.com/godfat/rest-core

## FEATURES:

* Concurrent requests
* Streaming requests

## REQUIREMENTS:

### Mandatory:

* Tested with MRI (official CRuby), Rubinius and JRuby.
* gem [rest-core][]
* gem [httpclient][]
* gem [mime-types][]
* gem [timers][]

[httpclient]: https://github.com/nahi/httpclient
[mime-types]: https://github.com/halostatue/mime-types
[timers]: https://github.com/celluloid/timers

### Optional:

* gem json or yajl-ruby, or multi_json

## INSTALLATION:

``` shell
gem install rest-firebase
```

Or if you want development version, put this in Gemfile:

``` ruby
gem 'rest-firebase', :git => 'git://github.com/CodementorIO/rest-firebase.git',
                     :submodules => true
```

## SYNOPSIS:

Check out Firebase's
[REST API documentation](https://www.firebase.com/docs/rest-api.html)
for a complete reference.

``` ruby
require 'rest-firebase'

f = RestFirebase.new :site => 'https://SampleChat.firebaseIO-demo.com/',
                     :secret => 'secret',
                     :d => {:auth_data => 'something'},
                     :log_method => method(:puts),
                     # `timeout` in seconds
                     :timeout => 10,
                     # `max_retries` upon failures. Default is: `0`
                     :max_retries => 3,
                     # `retry_exceptions` for which exceptions should retry
                     # Default is: `[IOError, SystemCallError]`
                     :retry_exceptions =>
                       [IOError, SystemCallError, Timeout::Error],
                     # `error_callback` would get called each time there's
                     # an exception. Useful for monitoring and logging.
                     :error_callback => method(:p),
                     # `auth_ttl` describes when we should refresh the auth
                     # token. Set it to `false` to disable auto-refreshing.
                     # The default is 23 hours.
                     :auth_ttl => 82800,
                     # `auth` is the auth token from Firebase. Leave it alone
                     # to auto-generate. Set it to `false` to disable it.
                     :auth => false # Ignore auth for this example!

@reconnect = true

# Streaming over 'users/tom'
es = f.event_source('users/tom')
es.onopen   { |sock| p sock } # Called when connected
es.onmessage{ |event, data, sock| p event, data } # Called for each message
es.onerror  { |error, sock| p error } # Called whenever there's an error
# Extra: If we return true in onreconnect callback, it would automatically
#        reconnect the node for us if disconnected.
es.onreconnect{ |error, sock| p error; @reconnect }

# Start making the request
es.start

# Try to close the connection and see it reconnects automatically
es.close

# Update users/tom.json
p f.put('users/tom', :some => 'data')
p f.post('users/tom', :some => 'other')
p f.get('users/tom')
p f.delete('users/tom')

# With Firebase queries (it would encode query in JSON for you)
p f.get('users/tom', :orderBy => '$key', :limitToFirst => 1)

# Need to tell onreconnect stops reconnecting, or even if we close
# the connection manually, it would still try to reconnect again.
@reconnect = false

# Close the connection to gracefully shut it down.
es.close

# Refresh the auth by resetting it
f.auth = nil
```

## Concurrent HTTP Requests:

Inherited from [rest-core][], you can do concurrent requests quite easily.
Here's a very quick example of making two API calls at the same time.

``` ruby
require 'rest-firebase'
firebase = RestFirebase.new(:log_method => method(:puts))
puts "httpclient with threads doing concurrent requests"
a = [firebase.get('users/tom'), firebase.get('users/mom')]
puts "It's not blocking... but doing concurrent requests underneath"
p a.map{ |r| r['name'] } # here we want the values, so it blocks here
puts "DONE"
```

If you prefer callback based solution, this would also work:

``` ruby
require 'rest-firebase'
firebase = RestFirebase.new(:log_method => method(:puts))
puts "callback also works"
firebase.get('users/tom') do |r|
  p r['name']
end
puts "It's not blocking... but doing concurrent requests underneath"
firebase.wait # we block here to wait for the request done
puts "DONE"
```

For a detailed explanation, see:
[Advanced Concurrent HTTP Requests -- Embrace the Future][future]

[future]: https://github.com/godfat/rest-core#advanced-concurrent-http-requests----embrace-the-future

### Thread Pool / Connection Pool

Underneath, rest-core would spawn a thread for each request, freeing you
from blocking. However, occasionally we would not want this behaviour,
giving that we might have limited resource and cannot maximize performance.

For example, maybe we could not afford so many threads running concurrently,
or the target server cannot accept so many concurrent connections. In those
cases, we would want to have limited concurrent threads or connections.

``` ruby
RestFirebase.pool_size = 10
RestFirebase.pool_idle_time = 60
```

This could set the thread pool size to 10, having a maximum of 10 threads
running together, growing from requests. Each threads idled more than 60
seconds would be shut down automatically.

Note that `pool_size` should at least be larger than 4, or it might be
very likely to have _deadlock_ if you're using nested callbacks and having
a large number of concurrent calls.

Also, setting `pool_size` to `-1` would mean we want to make blocking
requests, without spawning any threads. This might be useful for debugging.

### Gracefully shutdown

To shutdown gracefully, consider shutdown the thread pool (if we're using it),
and wait for all requests for a given client. For example:

``` ruby
RestFirebase.shutdown
```

We could put them in `at_exit` callback like this:

``` ruby
at_exit do
  RestFirebase.shutdown
end
```

If you're using unicorn, you probably want to put that in the config.

## Powered sites:

* [Codementor][]

## CHANGES:

* [CHANGES](CHANGES.md)

## CONTRIBUTORS:

* Lin Jen-Shin (@godfat)
* Yoshihiro Ibayashi (@chanibarin)

## LICENSE:

Apache License 2.0

Copyright (c) 2014-2015, Codementor

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
