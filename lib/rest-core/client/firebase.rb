
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
      use ErrorHandler, lambda{ |env| Firebase::Error.call(env) }
      use ErrorDetectorHttp
      use JsonResponse, true
    end
  end
end

class RestCore::Firebase::Error < RestCore::Error
  include RestCore
  class ServerError         < Firebase::Error; end
  class ClientError         < RestCore::Error; end

  class BadRequest          < Firebase::Error; end
  class Unauthorized        < Firebase::Error; end
  class Forbidden           < Firebase::Error; end
  class NotFound            < Firebase::Error; end
  class NotAcceptable       < Firebase::Error; end
  class ExpectationFailed   < Firebase::Error; end

  class InternalServerError < Firebase::Error::ServerError; end
  class BadGateway          < Firebase::Error::ServerError; end
  class ServiceUnavailable  < Firebase::Error::ServerError; end

  attr_reader :error, :code, :url
  def initialize error, code, url=''
    @error, @code, @url = error, code, url
    super("[#{code}] #{error.inspect} from #{url}")
  end

  def self.call env
    error, code, url = env[RESPONSE_BODY], env[RESPONSE_STATUS],
                       env[REQUEST_URI]
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

module RestCore::Firebase::Client
  include RestCore

  class EventSource < RestCore::EventSource
    def onmessage event=nil, sock=nil
      if event
        super(event.merge('data' => Json.decode(event['data'])), sock)
      else
        super
      end
    end
  end

  def request env, app=app
    super(env.merge(REQUEST_PATH    => "#{env[REQUEST_PATH]}.json",
                    REQUEST_PAYLOAD => Json.encode(env[REQUEST_PAYLOAD])),
          app)
  end

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

  private
  def base64url str; [str].pack('m').tr('+/', '-_'); end
  def default_query; {:auth => auth}; end
  def default_auth ; generate_auth  ; end
end

class RestCore::Firebase
  include RestCore::Firebase::Client
  self.event_source_class = EventSource
end
