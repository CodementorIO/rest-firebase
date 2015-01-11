
require 'rest-firebase'

es = RestFirebase.new(:auth => false).
       event_source('https://SampleChat.firebaseIO-demo.com/')

es.onerror do |error|
  puts "ERROR: #{error}"
end

es.onreconnect do
  !!@start # always reconnect unless stopping
end

es.onmessage do |event, data|
  puts "EVENT: #{event}, DATA: #{data}"
end

puts "Starting..."
@start = true
es.start

rd, wr = IO.pipe

Signal.trap('INT') do # intercept ctrl-c
  puts "Stopping..."
  @start = false      # stop reconnecting
  es.close            # close socket
  es.wait             # wait for shutting down
  wr.puts             # unblock main thread
end

rd.gets               # main thread blocks here

# Now try:
# curl -X POST -d '{"message": "Hi!"}' https://SampleChat.firebaseIO-demo.com/godfat.json
