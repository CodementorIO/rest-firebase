
# Codementor introduces you a new Firebase client for Ruby

## Why we pick Firebase

Here at Codementor we implemented all the realtime facilities with
[Firebase][], which is a great tool and service for realtime communication,
especially for their JavaScript library which could handle all those edge
cases like whenever the clients disconnected unexpectedly, how we could
process the data offline and when we have a chance to reconnect, reconnect
and resend the offline data, etc, which are definitely common enough and we
shall not ignore them.

[Firebase]: https://www.firebase.com/

## Why we need a Firebase client for Ruby

However, our server is written in Ruby, and we definitely need someway to let
the server communicate with the clients (browsers). For example, whenever
we want to programmatically broadcast some messages to certain users, it
would be much easier to do this from the server. Picking a Firebase client
for Ruby would be the most straightforward choice.

## Existing Firebase client for Ruby did not fit our need

Unfortunately, eventually we realized that the existing Firebase client for
Ruby, namely [firebase-ruby][], did not fit our need. The main reason is that
it did not support the [streaming feature from Firebase][streaming], which is
extremely important whenever we want the clients periodically notify the
server, (e.g. online presence) since the server needs to know the status in
order to do some other stuffs underneath in realtime. We could probably
implement this on our server, but why not just use Firebase whenever it's
already implemented, and we're using it?

[firebase-ruby]: https://github.com/oscardelben/firebase-ruby
[streaming]: https://www.firebase.com/docs/rest-api.html#streaming-from-the-rest-api

## [rest-firebase][]

Therefore we implemented our own Firebase client for Ruby, that is
[rest-firebase][]. It was built on top of [rest-core][], thus it has all
the advantages from rest-core, just like firebase-ruby was built on top
of [typhoeus][]. The highlights for rest-firebase are:

* Concurrent/asynchronous requests
* Streaming requests
* Generate Firebase JWT for you (auto-refresh is WIP)

[rest-firebase]: https://github.com/CodementorIO/rest-firebase
[rest-core]: https://github.com/godfat/rest-core
[typhoeus]: https://github.com/typhoeus/typhoeus

### Concurrent/asynchronous requests

At times we want to notify two users at the same time, instead of preparing
two requests and wait for two requests to be done, we could simply do this:
(not a working example, just try to demonstrate, see [README.md][] for
working example)

``` ruby
f = RestFirebase.new
f.put("users/#{a.id}", :message => 'Hi')
f.put("users/#{b.id}", :message => 'Oh')
```

All requests are non-blocking, and it would only block when we try to look at
the response. Therefore the above requests would be processed concurrently and
asynchronously. To learn more about this, check [Concurrent HTTP Requests][].

Also, consequently, if you're not waiting for the requests to be done
somewhere, you might want to wait `at_exit` to make sure all
requests are properly done like this:

``` ruby
at_exit do
  RestFirebase.shutdown
end
```

Which would also shutdown the [thread pool][] if you're using it.

[README.md]: https://github.com/CodementorIO/rest-firebase/blob/master/README.md
[Concurrent HTTP Requests]: https://github.com/CodementorIO/rest-firebase/blob/master/README.md#concurrent-http-requests
[thread pool]: https://github.com/godfat/rest-core#thread-pool--connection-pool

### Streaming requests

To receive the online presence events, we have a specialized daemon to listen
on the presence node from Firebase. Something like below:

``` ruby
es = RestFirebase.new.event_source('presence')
es.onerror do |error|
  Codementor.handle_error(error) unless error.kind_of?(EOFError)
end

es.onreconnect do
  firebase.auth = nil # refresh auth
  !!@start # don't reconnect if we're closing
end

es.onmessage do |event, data|
  next unless event == 'put'
  next unless username = data['path'][%r{^/(\w+)/web$}, 1]
  onpresence(username, data['data'])
end

es.start
sleep(1) while @start

es.close
```

`onpresence` is the one doing our business logic.

### Generate Firebase JWT for you (auto-refresh is WIP)

We could use Firebase JWT instead of our secret in order to make authorized
requests. This would be much secure than simply use the secret, which would
never expire unless we explicitly ask for. Checkout
[Authenticating Your Server][] for more detail. [rest-firebase][] could
generate one for you automatically by passing your secret to it like this:

``` ruby
f = RestFirebase.new :secret => 'secret',
                     :d => {:auth_data => 'something'}
f.get('presence') # => attach JWT for auth in the request automatically
f.auth            # => the JWT
f.auth = nil      # => remove old JWT
f.auth            # => generate a fresh new JWT
```

Read the above document for what `:d` means here. Note that this JWT
would expire after 24 hours. Every time you initialize a new `RestFirebase`
it would generate a fresh new JWT, but if you want to keep using the same
instance, you would probably need to refresh the JWT by yourselves, just like
what we did when we tried to reconnect it in the streaming example.

[Authenticating Your Server]: https://www.firebase.com/docs/security/custom-login.html#authenticating-your-server

## Summary

In order to take the full advantage of using Firebase with Ruby, we introduce
you [rest-firebase][], which highlights:

* Concurrent/asynchronous requests
* Streaming requests
* Generate Firebase JWT for you (auto-refresh is WIP)

Please feel free to try it and use it. It's released under Apache License 2.0.
