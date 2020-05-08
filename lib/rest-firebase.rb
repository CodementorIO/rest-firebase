
require 'rest-core'
require 'rest-core/util/json'
require 'rest-core/util/hmac'

# https://www.firebase.com/docs/security/custom-login.html
# https://www.firebase.com/docs/rest-api.html
# https://www.firebase.com/docs/rest/guide/retrieving-data.html#section-rest-queries
RestFirebaseBase =
  RestCore::Builder.client(:auth, :auth_ttl, :iat) do
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

# TODO: change this into a module (namespace),
#       prefer RestFirebase::Client2 as the client in the future
class RestFirebase < RestFirebaseBase
end

require 'rest-firebase/error'
require 'rest-firebase/event_source'
require 'rest-firebase/imp'

class RestFirebaseBase
  include RestFirebase::Imp
  self.event_source_class = RestFirebase::EventSource
end

class RestFirebase < RestFirebaseBase
  # TODO: remove this after we have proper module
  self.event_source_class = RestFirebase::EventSource

  attr_accessor :d, :secret

  def generate_auth opts={}
    raise Error::ClientError.new("Please set your secret") unless secret

    self.iat = nil
    header = {:typ => 'JWT', :alg => 'HS256'}
    claims = {:v => 0, :iat => iat, :d => d}.merge(opts)
    generate_jwt(header, claims)
  end

  def sign input
    RestCore::Hmac.sha256(secret, input)
  end
end

RestFirebase::Client2 = RestFirebase

class RestFirebase::Client3 < RestFirebaseBase
  AUD = 'https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit'

  attr_accessor :claims, :private_key, :service_account, :uid, :kid

  def generate_auth opts={}
    raise Error::ClientError.new("Please set your private_key") unless
      private_key
    raise Error::ClientError.new("Please set your service account") unless
      service_account

      self.iat = nil
      jwt_header = {:typ => 'JWT', :alg => 'RS256', :kid => kid}
      jwt_claims = {:iss => service_account, :sub => service_account,
                    :aud => AUD, :iat => iat, :claims => claims,
                    :exp => iat + 3600, :uid => uid}.merge(opts)
      generate_jwt(jwt_header, jwt_claims)
  end

  def sign input
    OpenSSL::PKey::RSA.new(private_key).sign('sha256', input)
  end
end
