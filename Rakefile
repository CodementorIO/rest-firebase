
begin
  require "#{__dir__}/task/gemgem"
rescue LoadError
  sh 'git submodule update --init --recursive'
  exec Gem.ruby, '-S', $PROGRAM_NAME, *ARGV
end

Gemgem.init(__dir__, :submodules =>
  %w[rest-core
     rest-core/rest-builder
     rest-core/rest-builder/promise_pool]) do |s|
  s.name     = 'rest-firebase'
  s.version  = '1.1.0'
  s.homepage = 'https://github.com/CodementorIO/rest-firebase'

  s.authors  = ['Codementor', 'Lin Jen-Shin (godfat)']
  s.email    = ['help@codementor.io']

  s.add_runtime_dependency('rest-core', '>=4.0.0')
end
