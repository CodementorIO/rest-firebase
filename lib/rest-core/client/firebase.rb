
require 'rest-core'

# https://www.firebase.com/docs/security/custom-login.html
# https://www.firebase.com/docs/rest-api.html
module RestCore
  Firebase = Builder.client(:d, :secret, :auth) do
    use Timeout       , 10

    use DefaultSite   , 'https://SampleChat.firebaseIO-demo.com/'
    use DefaultHeaders, {'Accept' => 'application/json'}
    use DefaultQuery  , nil

    use FollowRedirect, 1
    use CommonLogger  , nil
    use Cache         , nil, 600 do
      use ErrorHandler, lambda{ |env|
        RuntimeError.new(env[RESPONSE_BODY]['message'])}
      use ErrorDetectorHttp
      use JsonResponse, true
    end
  end
end

module RestCore::Firebase::Client
  include RestCore

  def generate_auth opts={}
    raise Firebase::Error::ClientError.new(
      "Please set your secret") unless secret

    header = {:typ => 'JWT', :alg => 'HS256'}
    claims = {:v => 0, :iat => Time.now.to_i, :d => d}.merge(opts)
    # http://tools.ietf.org/html/draft-ietf-jose-json-web-signature-26
    input = [header, claims].map{ |d| base64url(Json.encode(d)) }.join('.')
    # http://tools.ietf.org/html/draft-ietf-oauth-json-web-token-20
    "#{input}.#{base64url(Hmac.sha256(secret, input))}"
  end

  def request env, app=app
    super(env.merge(REQUEST_PATH    => "#{env[REQUEST_PATH]}.json",
                    REQUEST_PAYLOAD => Json.encode(env[REQUEST_PAYLOAD])),
          app)
  end

  private
  def base64url str; [str].pack('m').tr('+/', '-_'); end
  def default_query; {:auth => auth}; end
  def default_auth ; generate_auth  ; end
end

class RestCore::Firebase
  include RestCore::Firebase::Client
end
