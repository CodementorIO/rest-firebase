
begin
  require "#{dir = File.dirname(__FILE__)}/task/gemgem"
rescue LoadError
  sh 'git submodule update --init --recursive'
  exec Gem.ruby, '-S', $PROGRAM_NAME, *ARGV
end

$LOAD_PATH.unshift(File.expand_path("#{dir}/rest-core/lib"))
$LOAD_PATH.unshift(File.expand_path("#{dir}/rest-core/promise_pool/lib"))

Gemgem.init(dir) do |s|
  s.name     = 'rest-firebase'
  s.version  = '1.0.3'
  s.homepage = 'https://github.com/CodementorIO/rest-firebase'

  s.authors  = ['Codementor', 'Lin Jen-Shin (godfat)']
  s.email    = ['help@codementor.io']

  %w[rest-core].each{ |g| s.add_runtime_dependency(g, '>=3.5.0') }

  # exclude rest-core
  s.files.reject!{ |f| f.start_with?('rest-core/') }
end

task 'test' do
  SimpleCov.add_filter('rest-core/lib') if ENV['COV'] || ENV['CI']
end
