require 'rubygems'
require 'rspec/core/rake_task'
require 'cucumber'
require 'cucumber/rake/task'
require 'listen'


desc "Run server"

task :serverup do
  
  #listen and rebuild javascript file
  system "./build_tools/create_one_js.sh"
  listener = Listen.to('web/public/js').ignore(%r{app.js})
  callback = lambda {|changed,created,deleted| system "./build_tools/create_one_js.sh"  }
  listener.change(&callback) # convert the callback to a block and register it
  listener.start(false)

  system "rackup -p 3000 &"
end

task :serverdown do
  system "pkill -9 -f rackup"
end

namespace :test do

  desc "Run lib tests"
  RSpec::Core::RakeTask.new(:lib) do |t|
      t.pattern = "test/lib/*.rb"
      t.rspec_opts = " -c --format documentation"
  end

	desc "Run domain tests"
	RSpec::Core::RakeTask.new(:domain) do |t|
      t.pattern = FileList['test/lib/*.rb', '*/test/domain/*.rb']
	    t.rspec_opts = " -c --format documentation"
	end

  desc "Run integration rspec tests"
  RSpec::Core::RakeTask.new(:rspecintegration) do |t|
      t.pattern = FileList['*/test/integration/*.rb']
      t.rspec_opts = " -c --format documentation"
  end

	desc "Run all tests"
	task :all do
    Rake::Task['test:domain'].execute
		Rake::Task['test:integration'].execute
	end

  task :integration do
    Rake::Task['test:rspecintegration'].execute
    Rake::Task['test:cucumberintegration'].execute
  end

  desc "Run jasmine specs"
  Cucumber::Rake::Task.new(:jasmine) do |t|
        t.cucumber_opts = "Specs"
  end

	desc "Run integrationtest"
	Cucumber::Rake::Task.new(:cucumberintegration) do |t|
  	    t.cucumber_opts = "IntegrationTest --tags ~@ignored"
	end

  desc "Run wip"
  task :wip do
    Rake::Task['test:wipintegration'].execute
  end

  desc "Run wip integration"
  Cucumber::Rake::Task.new(:wipintegration) do |t|
        t.cucumber_opts = "IntegrationTest --tags @wip"
  end

end


 desc "deploy to heroku pre"
  task :deploy do
   system "./build_tools/deploy.sh"
 end

desc "Check the JavaScript source with JSLint - exit with status 1 if any of the files fail."
task :jslint do
  failed_files = []
  Dir['web/public/js/ZZ/**/*.js'].each do |fname|
    results = `java -jar ./build_tools/rhino.jar ./build_tools/jshint-rhino.js #{fname}`
    if results != ""
      puts "#{fname}:"
      puts results
      failed_files << fname
    end
  end
  if failed_files.size > 0
    exit 1
  end
end
