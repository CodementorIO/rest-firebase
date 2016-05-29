
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
