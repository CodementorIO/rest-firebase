
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

class RestFirebase::Error < RestCore::Error
  class ServerError         < RestFirebase::Error; end
  class ClientError         < RestCore::Error; end

  class BadRequest          < RestFirebase::Error; end
  class Unauthorized        < RestFirebase::Error; end
  class Forbidden           < RestFirebase::Error; end
  class NotFound            < RestFirebase::Error; end
  class NotAcceptable       < RestFirebase::Error; end
  class ExpectationFailed   < RestFirebase::Error; end

  class InternalServerError < RestFirebase::Error::ServerError; end
  class BadGateway          < RestFirebase::Error::ServerError; end
  class ServiceUnavailable  < RestFirebase::Error::ServerError; end

  attr_reader :error, :code, :url
  def initialize error, code, url=''
    @error, @code, @url = error, code, url
    super("[#{code}] #{error.inspect} from #{url}")
  end

  def self.call env
    error, code, url = env[RestCore::RESPONSE_BODY],
                       env[RestCore::RESPONSE_STATUS],
                       env[RestCore::REQUEST_URI]
    return new(error, code, url) unless error.kind_of?(Hash)
    case code
      when 400; BadRequest
      when 401; Unauthorized
      when 403; Forbidden
      when 404; NotFound
      when 406; NotAcceptable
      when 417; ExpectationFailed
      when 500; InternalServerError
      when 502; BadGateway
      when 503; ServiceUnavailable
      else    ; self
    end.new(error, code, url)
  end
end

module RestFirebase::Client
  class EventSource < RestCore::EventSource
    def onmessage event=nil, data=nil, sock=nil
      if event
        super(event, RestCore::Json.decode(data), sock)
      else
        super
      end
    end
  end

  def request env, a=app
    check_auth
    query = env[RestCore::REQUEST_QUERY].inject({}) do |q, (k, v)|
      q[k] = RestCore::Json.encode(v)
      q
    end
    super(env.merge(RestCore::REQUEST_PATH =>
                      "#{env[RestCore::REQUEST_PATH]}.json",
                    RestCore::REQUEST_QUERY => query), a)
  end

  def generate_auth opts={}
    raise RestFirebase::Error::ClientError.new(
      "Please set your secret") unless secret

    self.iat = nil
    header = {:typ => 'JWT', :alg => 'HS256'}
    claims = {:v => 0, :iat => iat, :d => d}.merge(opts)
    # http://tools.ietf.org/html/draft-ietf-jose-json-web-signature-26
    input = [header, claims].map{ |d| base64url(RestCore::Json.encode(d)) }.
            join('.')
    # http://tools.ietf.org/html/draft-ietf-oauth-json-web-token-20
    "#{input}.#{base64url(RestCore::Hmac.sha256(secret, input))}"
  end

  def query
    {:auth => auth}
  end

  private
  def base64url str; [str].pack('m0').tr('+/', '-_'); end
  def default_auth    ; generate_auth  ; end
  def default_auth_ttl; 82800          ; end
  def default_iat     ; Time.now.to_i  ; end

  def check_auth
    self.auth = nil if auth_ttl && Time.now.to_i - iat > auth_ttl
  end
end

class RestFirebase
  include RestFirebase::Client
  self.event_source_class = EventSource
  const_get(:Struct).send(:remove_method, :query=)
end
