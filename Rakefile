
begin
  require "#{dir = File.dirname(__FILE__)}/task/gemgem"
rescue LoadError
  sh 'git submodule update --init'
  exec Gem.ruby, '-S', $PROGRAM_NAME, *ARGV
end

$LOAD_PATH.unshift(File.expand_path("#{dir}/rest-core/lib"))

Gemgem.init(dir) do |s|
  s.name     = 'rest-firebase'
  s.version  = '0.9.5'
  s.homepage = 'https://github.com/CodementorIO/rest-firebase'

  s.authors  = ['Codementor', 'Lin Jen-Shin (godfat)']
  s.email    = ['help@codementor.io']

  %w[rest-core].each{ |g| s.add_runtime_dependency(g, '>=3.3.0') }

  # exclude rest-core
  s.files.reject!{ |f| f.start_with?('rest-core/') }
end
