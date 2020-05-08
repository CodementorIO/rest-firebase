
class RestFirebase::EventSource < RestCore::EventSource
  def onmessage event=nil, data=nil, sock=nil
    if event
      super(event, RestCore::Json.decode(data), sock)
    else
      super
    end
  end
end
