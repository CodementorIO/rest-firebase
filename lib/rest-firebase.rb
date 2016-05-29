
require 'rest-core'
require 'rest-core/util/json'
require 'rest-core/util/hmac'

# https://www.firebase.com/docs/security/custom-login.html
# https://www.firebase.com/docs/rest-api.html
# https://www.firebase.com/docs/rest/guide/retrieving-data.html#section-rest-queries
RestFirebase =
  RestCore::Builder.client(:d, :secret, :auth, :auth_ttl, :iat) do
    use RestCore::DefaultSite   , 'https://SampleChat.firebaseIO-demo.com/'
    use RestCore::DefaultHeaders, {'Accept' => 'application/json',
                             'Content-Type' => 'application/json'}
    use RestCore::DefaultQuery  , nil
    use RestCore::JsonRequest   , true

    use RestCore::Retry         , 0, RestCore::Retry::DefaultRetryExceptions
    use RestCore::Timeout       , 10
    use RestCore::FollowRedirect, 5
    use RestCore::ErrorHandler  , lambda{|env| RestFirebase::Error.call(env)}
    use RestCore::ErrorDetectorHttp
    use RestCore::JsonResponse  , true
    use RestCore::CommonLogger  , nil
    use RestCore::Cache         , nil, 600
  end


require 'rest-firebase/error'
require 'rest-firebase/client'

class RestFirebase
  include RestFirebase::Client
  self.event_source_class = EventSource
  const_get(:Struct).send(:remove_method, :query=)
end
