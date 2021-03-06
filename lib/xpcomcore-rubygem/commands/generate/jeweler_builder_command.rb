require "xpcomcore-rubygem/commands/generate/template_helpers"
require "english"
require "shell"
require "stringio"

module XPCOMCore
  class CommandParser
    class GenerateCommand

      class JewelerBuilderCommand < CmdParse::Command
        include TemplateHelpers
        
        JewelerSuccess = /Jeweler has prepared your gem in (.*)/
        DefaultJewelerOpts = %w[--testunit]
        ApplicableJewelerOpts = {
          "--create-repo"               => "create the repository on GitHub",
          "--gemcutter"                 => "setup project for gemcutter",
          "--summary [SUMMARY]"         => "specify the summary of the project",
          "--description [DESCRIPTION]" => "specify a description of the project",
          "--directory [DIRECTORY]"     => "specify the directory to generate into"
        }
        DefaultGemDependencies = {'xpcomcore-rubygem' => ">=#{XPCOMCore::Version}",
                                  'riot-js'           => ">0.0.0"}
        RakefileGemDepFormat = "    gem.add_dependency %s, %s"
        RakefileGemSpecLine = /# gem is a Gem::Specification/
        
        def initialize(*args)
          super(*args)
          @jeweler_opts = {}
        end
                  
        def execute(args)
          gem_name = args.shift || raise(CmdParse::InvalidArgumentError, "A name must be given")
          project_path = Pathname(Dir.pwd) + make_jeweler_project(gem_name)
          with_rakefile_in(project_path) { |rakefile| add_gem_dependencies(rakefile) }
          rewrite_stub_ruby_file(gem_name, project_path)
          setup_project(gem_name, project_path)
        end
        
      private
      
        def setup_project(gem_name, project_path)
          raise NotImplementedError
        end
        
        def rewrite_stub_ruby_file(gem_name, project_path)
          (project_path + "lib" + "#{gem_name}.rb").open('w') do |f|
            f << "warn('This is a stub file generated by xpcomcore-rubygem. There may in fact be no Ruby code to speak of in this gem.')"
          end
        end
        
        def add_gem_dependencies(rakefile)
          new_rakefile = rakefile.readlines.inject([]) do |new_rake,line|
            if line =~ RakefileGemSpecLine
              new_rake.concat(DefaultGemDependencies.collect { |dep,ver| RakefileGemDepFormat % [dep.inspect, ver.inspect] })
            end
            new_rake << line.chomp
          end
          rakefile.rewind && rakefile.write(new_rakefile.join($RS))
        end
        
        def with_rakefile_in(project_path)
          (project_path + "Rakefile").open("r+") { |f| yield(f) }
        end

        def make_jeweler_project(gem_name)
          # FIXME - ugh. jeweler doesn't return non-zero exit on failure.
          captured, sh, jeweler_args = StringIO.new, Shell.new, make_jeweler_args
          sh.out(captured) { sh.system("jeweler", gem_name, *jeweler_args) }
          captured = captured.rewind && captured.read
          (captured =~ JewelerSuccess) ? (return($1)) : raise(GenerationError, "Failed to generate your project using Jeweler.")
        ensure
          puts captured
        end

        def add_jeweler_opts(opt_parse)
          ApplicableJewelerOpts.each do |switch,desc|
            switch_name = switch.split(" ", 2)[0]
            opt_parse.on(switch, desc) {|val| @jeweler_opts[switch_name] = val }
          end
        end
        
        def make_jeweler_args
          @jeweler_opts.inject(DefaultJewelerOpts.dup) do |args,(opt_switch,opt_val)|
            opt_val == true ? args.push(opt_switch) : args.push(opt_switch, opt_val)
          end
        end
      
        def add_jsdoc_toolkit_doc_task(rakefile, options)
          append_to(rakefile, eval_template("shared/jsdoc_doc_task.erb", options))
        end

        def add_xultestrunner_test_task(rakefile, options)
          append_to(rakefile, eval_template("shared/xultestrunner_test_task.erb", options))
        end
        
        def append_to(io, str, add_newlines = true)
          io.seek(0, IO::SEEK_END)
          io << $RS * 2 if add_newlines
          io << str
        end
        
      end # JewelerBuilderCommand
      
    end   # GenerateCommand
  end     # CommandParser
end       # XPCOMCore
      