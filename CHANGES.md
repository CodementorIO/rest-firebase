# CHANGES

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
