require 'rubygems'
require 'xpcomcore-rubygem/commands'
require 'sys/uname'
require 'pathname'
require 'iniparse'
require 'tempfile'

module XPCOMCore
  class CommandParser
    class LaunchCommand < CmdParse::Command
      attr_accessor :use_xulrunner

      class ApplicationNotFoundError < CmdParse::InvalidArgumentError
        reason 'Application not found'
      end
      
      class BaseLauncher
        class XULRunnerNotFoundError < CmdParse::ParseError
          reason 'XULRunner not found'
        end
        
        def initialize(options)
          @options = options
        end
        
        def launch
          ENV['XPCOMCORE'] = ENV['XPCOMCORE'] || XPCOMCore::BootstrapperLocation.to_s
          XPCOMCore::CommandParser.log("Using XPCOMCore bootstrapper at '#{ENV['XPCOMCORE']}'")
        end
        
      private
        
        def launch_xre(xre_location)
          XPCOMCore::CommandParser.log("Launching XUL application using XULRunner '#{xre_location}' from '#{@options[:ini_path].expand_path}'")
          exec(xre_location, *["-app", @options[:ini_path].expand_path.to_s, "-no-remote", *@options[:args]])
        end
        
        def raise_xulrunner_not_found(search_location, runner_type)
          raise(XULRunnerNotFoundError, "Sorry, we couldn't find #{runner_type}. We checked in #{search_location} but it didn't seem to be there.")
        end
        
      end # BaseLauncher
      
      class DarwinLauncher < BaseLauncher
        StubLocationRelativeToIni = "../../stub_runners/%s.app"

        def launch
          super
          xre_location = send(:"locate_#{@options[:runner_type]}")
          if stub_location = find_stub
            launch_from_stub(xre_location, stub_location)
          else
            launch_xre(xre_location)
          end
        end
        
      private
        
        def launch_from_stub(xre_location, stub_location)
          ENV['REAL_EXECUTABLE'] = xre_location.to_s
          XPCOMCore::CommandParser.log("Launching XUL application using stub '#{stub_location}' and XULRunner '#{xre_location}' from '#{@options[:ini_path].expand_path}'")
          prepare_for_output_hijacking
          system("open", stub_location.to_s, "--args", *["-app", @options[:ini_path].expand_path.to_s, "-no-remote", *@options[:args]])
          puts "I helpfully hijacked stdout and stderr back from LaunchServices for you. What follows is coming from your application."
          exec(%Q[cat "#{ENV['HIJACKED_STDOUT']}" & cat "#{ENV['HIJACKED_STDERR']}" >&2])
        end
        
        def prepare_for_output_hijacking
          ENV['HIJACK_OUTPUT'] = 'true'
          output_file, error_file = Tempfile.new("stdout.pipe."), Tempfile.new("stdout.pipe.")
          output_path, error_path = output_file.path, error_file.path
          output_file.close!
          error_file.close!
          system("mkfifo", "-m", "600", output_path) && system("mkfifo", "-m", "600", error_path)
          ENV['HIJACKED_STDOUT'] = output_path
          ENV['HIJACKED_STDERR'] = error_path
        end
        
        def find_stub
          parsed_ini = IniParse.parse(@options[:ini_path].read)
          app_name = parsed_ini['App']['Name']
          stub_path = (@options[:ini_path] + (StubLocationRelativeToIni % app_name)).expand_path
          stub_path.exist? ? stub_path : nil
        end
        
        def locate_firefox
          applications = `osascript -e 'POSIX path of (path to applications folder)'`.strip
          firefox_bin = (Pathname(applications) + "Firefox.app/Contents/MacOS/firefox-bin").expand_path
          firefox_bin.exist? ? firefox_bin.to_s : raise_xulrunner_not_found(firefox_bin, "Firefox")
        end
            
        def locate_xulrunner
          library = `osascript -e 'POSIX path of (path to library folder)'`.strip
          xulrunner_bin = (Pathname(library) + "Frameworks/XUL.framework/xulrunner-bin").expand_path
          xulrunner_bin.exist? ? xulrunner_bin.to_s : raise_xulrunner_not_found(xulrunner_bin, "XULRunner")
        end

      end # DarwinLauncher
      
      class LinuxLauncher < BaseLauncher
        
        def launch
          super
          xre_location = send(:"locate_#{@options[:runner_type]}")
          launch_xre(xre_location)
        end
        
      private
        
        def locate_firefox
          firefox_bin = [`which firefox-bin`, `which firefox`].detect do |path|
            !path.strip.empty?
          end
          firefox_bin ? firefox_bin.strip : raise_xulrunner_not_found("$PATH", "Firefox")
        end
        
        def locate_xulrunner
          xulrunner_bin = [`which xulrunner-bin`, `which xulrunner`].detect do |path|
            !path.strip.empty?
          end
          xulrunner_bin ? xulrunner_bin.strip : raise_xulrunner_not_found("$PATH", "XULRunner")
        end

      end # LinuxLauncher
      
      GemAppRelativePath = "xpcomcore/app/application.ini"
      CurrentPlatform = Sys::Uname.sysname.downcase.to_sym
      
      def initialize
        super('launch', false, # Doesn't take subcommands
                        true)  # Uses partial command matching
        self.short_desc = "Launches an XPCOMCore based XUL application either from RubyGems or a given path"
        self.options = CmdParse::OptionParserWrapper.new do |opt|
          opt.on('-x', '--use-xulrunner', 'Tries to use XULRunner to launch the given application rather than the default of Firefox', method(:use_xulrunner=))
        end
      end
      
      def execute(args)
        app_name_or_path = args.shift || '.'
        application = find_app(app_name_or_path)
        unless application
          raise(ApplicationNotFoundError, "The application '#{app_name_or_path}' could not be found in the given path or in your RubyGems install")
        end
        launch_app(application, args)
      end
      
      def use_xulrunner?
        !!use_xulrunner
      end
      
      def runner_type
        use_xulrunner? ? :xulrunner : :firefox
      end
      
    private
    
      def launch_app(application_ini_path, args)
        launcher_class = self.class.const_get(:"#{CurrentPlatform.to_s.capitalize}Launcher")
        launcher = launcher_class.new(:ini_path => application_ini_path, :runner_type => runner_type, :args => args)
        launcher.launch
      rescue NameError => e
        puts "Probably couldn't get a launcher for your platform. Sorry. #{e}"
      end
            
      def find_app(app_path)
        fs_path = Pathname(Dir.pwd) + app_path + "application.ini"
        if fs_path.exist?
          return fs_path
        else
          return search_gems(app_path)
        end
      end
      
      def search_gems(app_name)
        gems = Gem.source_index.find_name(app_name)
        return nil if gems.empty?
        latest_gem_spec = gems.last
        get_application_path_from_gem_spec(latest_gem_spec)
      end

      def get_application_path_from_gem_spec(gem_spec)
        ini_path = Pathname(gem_spec.full_gem_path) + GemAppRelativePath
        if ini_path.exist?
          return ini_path
        else
          return nil
        end
      end
      
    end # LaunchCommand
  end   # CommandParser
end     # XPCOMCore

XPCOMCore::CommandParser.add_command(XPCOMCore::CommandParser::LaunchCommand)