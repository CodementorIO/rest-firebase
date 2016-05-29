
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
