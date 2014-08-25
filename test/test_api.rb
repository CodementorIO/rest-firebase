
require 'rest-firebase'
require 'rest-core/test'

Pork::API.describe RestFirebase do
  before do
    stub(Time).now{ Time.at(86400) }
  end

  after do
    WebMock.reset!
    Muack.verify
  end

  path = 'https://a.json?auth=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9%0A.eyJ2IjowLCJpYXQiOjg2NDAwLCJkIjpudWxsfQ%3D%3D%0A.cAZWmKD66jARF-BXEi5J1aqJ6khDbFdPAfAqXVbGpZk%3D%0A'

  json = '{"status":"ok"}'
  rbon = {'status' => 'ok'}

  def firebase
    @firebase ||= RestFirebase.new(:secret => 'nnf')
  end

  would 'get true' do
    stub_request(:get, path).to_return(:body => 'true')
    firebase.get('https://a').should.eq true
  end

  would 'put {"status":"ok"}' do
    stub_request(:put, path).with(:body => json).to_return(:body => json)
    firebase.put('https://a', rbon).should.eq rbon
  end

  would 'have no payload for delete' do
    stub_request(:delete, path).with(:body => nil).to_return(:body => json)
    firebase.delete('https://a').should.eq rbon
  end

  would 'parse event source' do
    stub_request(:get, path).to_return(:body => <<-SSE)
event: put
data: {}

event: keep-alive
data: null

event: invalid
data: invalid
SSE
    m = [{'event' => 'put'       , 'data' => {}},
         {'event' => 'keep-alive', 'data' => nil}]
    es = firebase.event_source('https://a')
    es.should.kind_of? RestFirebase::Client::EventSource
    es.onmessage do |event, data|
      {'event' => event, 'data' => data}.should.eq m.shift
    end.onerror do |error|
      error.should.kind_of? RC::Json::ParseError
    end.start.wait
    m.should.empty?
  end

  would 'refresh token' do
    mock(Time).now{ Time.at(0) }
    auth = firebase.auth
    Muack.verify(Time)
    stub(Time).now{ Time.at(86400) }

    stub_request(:get, path).to_return(:body => 'true')
    firebase.get('https://a').should.eq true
    firebase.auth.should.not.eq auth
  end

  define_method :check do |status, klass|
    stub_request(:delete, path).to_return(
      :body => '{}', :status => status)

    lambda{ firebase.delete('https://a').tap{} }.should.raise(klass)

    WebMock.reset!
  end

  would 'raise exception when encountering error' do
    [400, 401, 402, 403, 404, 406, 417].each do |status|
      check(status, RestFirebase::Error)
    end
    [500, 502, 503].each do |status|
      check(status, RestFirebase::Error::ServerError)
    end
  end
end
