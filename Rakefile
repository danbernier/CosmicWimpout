require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/test*.rb']
end

task :default => :test

desc "Starts a command-line version of the game"
task :play do
  $LOAD_PATH.unshift './lib'
  require 'cosmic_wimpout'

  CosmicWimpout.start
end
