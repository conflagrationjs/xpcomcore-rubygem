# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{xpcomcore-rubygem}
  s.version = "0.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["ggironda"]
  s.date = %q{2009-10-10}
  s.default_executable = %q{xpcomcore}
  s.description = %q{Gem to allow for using XPCOMCore via RubyGems}
  s.email = %q{gabriel.gironda@gmail.com}
  s.executables = ["xpcomcore"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.markdown"
  ]
  s.files = [
    ".document",
     ".gitignore",
     ".gitmodules",
     "LICENSE",
     "README.markdown",
     "Rakefile",
     "VERSION",
     "bin/xpcomcore",
     "lib/xpcomcore-rubygem.rb",
     "lib/xpcomcore-rubygem/commands.rb",
     "lib/xpcomcore-rubygem/commands/generate.rb",
     "lib/xpcomcore-rubygem/commands/launch.rb",
     "templates/application/application.ini.erb",
     "templates/application/chrome/chrome.manifest.erb",
     "templates/application/chrome/content/xul/main_window.xul.erb",
     "templates/application/defaults/preferences/prefs.js.erb",
     "templates/shared/bootstrapper.js",
     "test/test_helper.rb",
     "test/xpcomcore-rubygem_test.rb",
     "xpcomcore-rubygem.gemspec",
     "xpcomcore/LICENSE",
     "xpcomcore/README",
     "xpcomcore/Rakefile",
     "xpcomcore/VERSION.yml",
     "xpcomcore/bin/popen_helper.sh",
     "xpcomcore/bootstrapper.js",
     "xpcomcore/components/XPCOMCore.js",
     "xpcomcore/doc/files.html",
     "xpcomcore/doc/index.html",
     "xpcomcore/doc/symbols/_global_.html",
     "xpcomcore/doc/symbols/error.html",
     "xpcomcore/doc/symbols/file.html",
     "xpcomcore/doc/symbols/file.nosuchfileerror.html",
     "xpcomcore/doc/symbols/kernel.html",
     "xpcomcore/doc/symbols/loaderror.html",
     "xpcomcore/doc/symbols/selfconcepterror.html",
     "xpcomcore/doc/symbols/src/lib_file.js.html",
     "xpcomcore/doc/symbols/src/lib_kernel.js.html",
     "xpcomcore/doc/symbols/src/lib_sys.js.html",
     "xpcomcore/doc/symbols/src/lib_xpc_builtins.js.html",
     "xpcomcore/doc/symbols/sys.html",
     "xpcomcore/doc/symbols/xpcbuiltins.html",
     "xpcomcore/lib/file.js",
     "xpcomcore/lib/kernel.js",
     "xpcomcore/lib/sys.js",
     "xpcomcore/lib/xpc_builtins.js",
     "xpcomcore/test/file_test.js",
     "xpcomcore/test/fixtures/empty",
     "xpcomcore/test/fixtures/love.js",
     "xpcomcore/test/fixtures/mad_love.js",
     "xpcomcore/test/fixtures/mad_world.js",
     "xpcomcore/test/fixtures/syntax_error.js",
     "xpcomcore/test/kernel_test.js",
     "xpcomcore/test/sys_test.js",
     "xpcomcore/test/xpc_builtins_test.js"
  ]
  s.homepage = %q{http://github.com/gabrielg/xpcomcore-rubygem}
  s.post_install_message = %q{[1m[31m[44m                                                                                
                                                                                
    STEP 1. OBTAIN A PIG. THIS ONE WILL DO:                                     
                                                                                
        _____                                                                   
    ^..^     \9                                                                 
    (oo)_____/                                                                  
       WW  WW    Pig                                                            
                                                                                [0m[0m}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Gem to allow for using XPCOMCore via RubyGems}
  s.test_files = [
    "test/test_helper.rb",
     "test/xpcomcore-rubygem_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sys-uname>, [">= 0"])
      s.add_runtime_dependency(%q<cmdparse>, [">= 0"])
      s.add_runtime_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<colored>, [">= 0"])
    else
      s.add_dependency(%q<sys-uname>, [">= 0"])
      s.add_dependency(%q<cmdparse>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<colored>, [">= 0"])
    end
  else
    s.add_dependency(%q<sys-uname>, [">= 0"])
    s.add_dependency(%q<cmdparse>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<colored>, [">= 0"])
  end
end
