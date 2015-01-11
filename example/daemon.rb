
require 'rest-firebase'

es = RestFirebase.new(:auth => false).
       event_source('https://SampleChat.firebaseIO-demo.com/')

es.onerror do |error|
  puts "ERROR: #{error}"
end

es.onreconnect do
  !!@start
end

es.onmessage do |event, data|
  puts "EVENT: #{event}, DATA: #{data}"
end

puts "Starting..."
@start = true
es.start

rd, wr = IO.pipe

Signal.trap('INT') do
  puts "Stopping..."
  @start = false
  es.close
  es.wait
  wr.puts
end

rd.gets

# Now try:
# curl -X POST -d '{"message": "Hi!"}' https://SampleChat.firebaseIO-demo.com/godfat.json
