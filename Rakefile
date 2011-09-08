require 'rake'

task :default => :test

task :test do
  require 'test/unit'
  $LOAD_PATH.push './lib'
  Dir.glob('test/*.rb').each { |f| require f }
end
