
module RestFirebase::Imp
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

  def generate_auth
    raise NotImplementedError
  end

  def sign _
    raise NotImplementedError
  end

  def generate_jwt header, claims
    # http://tools.ietf.org/html/draft-ietf-jose-json-web-signature-26
    input = [header, claims].map{ |d| base64url(RestCore::Json.encode(d)) }.
            join('.')
    # http://tools.ietf.org/html/draft-ietf-oauth-json-web-token-20
    "#{input}.#{base64url(sign(input))}"
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
