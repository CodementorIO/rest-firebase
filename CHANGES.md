# CHANGES

## rest-firebase 1.0.3 -- 2015-11-16

### Bugs fixed

* Raise the default `max_redirects` from 1 to 5 because Firebase introduced
  an extra redirect for EventSource. 2 is enough in theory but to make it
  more future compatible, we set the default to 5 for now. If Firebase
  really needs more than 5 redirects, you could also workaround this by
  setting `max_redirects` to another number while setting up the client.
  For example:

  ``` ruby
  client = RestFirebase.new(:max_redirects => 10)
  # or
  client = RestFirebase.new
  client.max_redirects = 10
  ```

  This works for any version of rest-firebase. Thanks @chanibarin
  See: <https://github.com/CodementorIO/rest-firebase/pull/7>

## rest-firebase 1.0.2 -- 2015-06-12

* Fixed a bug where it would try to encode JSON twice upon retrying.

## rest-firebase 1.0.1 -- 2015-01-04

* Ruby 2.2 compatibility

## rest-firebase 1.0.0 -- 2014-12-09

### Enhancement

* Encode query in JSON to make using [Firebase queries][] easy.
* Introduced `max_retries`, `retry_exceptions`, and `error_callback` from
  latest rest-core (3.5.0+). See README.md for detail.

[Firebase queries]: https://www.firebase.com/docs/rest/guide/retrieving-data.html#section-rest-queries

### Internal Enhancement

* Encode payload in JSON with middleware from rest-core

## rest-firebase 0.9.5 -- 2014-11-07

* Base64url encoded JWT would no longer contain any newlines.

## rest-firebase 0.9.4 -- 2014-09-01

* Should really properly refresh the auth (query)
* From now on you're not allowed to change the value of query.

## rest-firebase 0.9.3 -- 2014-08-25

* Adopted rest-core 3.3.0
* Introduce `RestFirebase#auth_ttl` to setup when to refresh the auth token.
  Default to 23 hours (82800 seconds)
* Properly refresh the auth token by resetting `RestFirebase#iat`.

## rest-firebase 0.9.2 -- 2014-08-06

* Now it would auto-refresh auth if it's also expired (>= 23 hours)

## rest-firebase 0.9.1 -- 2014-06-28

* Now it would properly send JSON payload and headers.

## rest-firebase 0.9.0 -- 2014-05-13

* Birthday!
