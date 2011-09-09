require 'rake'

task :default => :test

task :test do
  $LOAD_PATH.push './lib'
  Dir.glob('test/*.rb').each { |f| load f }
end
