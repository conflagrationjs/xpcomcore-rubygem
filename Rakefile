require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  require 'colored'
  
  Jeweler::Tasks.new do |gem|
    gem.name = "xpcomcore-rubygem"
    gem.executables = %w[xpcomcore-rubygem-install xpcomcore-firefox]
    gem.summary = %Q{Gem to allow for using XPCOMCore via RubyGems}
    gem.description = %Q{Gem to allow for using XPCOMCore via RubyGems}
    gem.email = "gabriel.gironda@gmail.com"
    gem.homepage = "http://github.com/gabrielg/xpcomcore-rubygem"
    gem.authors = ["ggironda"]
    gem.files = (gem.files + FileList["xpcomcore/**/*"]).uniq
    gem.post_install_message = %Q[

    STEP 1. OBTAIN A PIG. THIS ONE WILL DO:                         
 
        _____                                                       
    ^..^     \\9                                                     
    (oo)_____/                                                      
       WW  WW    Pig
   
].split("\n").collect { |l| l.ljust(80) }.join("\n").red_on_blue.bold

    gem.add_dependency "sys-uname"
    gem.add_development_dependency "colored"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "xpcomcore-rubygem #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

