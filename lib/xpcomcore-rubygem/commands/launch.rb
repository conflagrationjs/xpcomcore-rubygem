require 'rubygems'
require 'xpcomcore-rubygem/commands'
require 'sys/uname'
require 'pathname'

module XPCOMCore
  class CommandParser
    class LaunchCommand < CmdParse::Command
      attr_accessor :use_xulrunner

      class ApplicationNotFoundError < CmdParse::InvalidArgumentError
        reason 'Application not found'
      end
      
      class XULRunnerNotFoundError < CmdParse::ParseError
        reason 'XULRunner not found'
      end
      
      GemAppRelativePath = "xpcomcore/app/application.ini"
      CurrentPlatform = Sys::Uname.sysname.downcase.to_sym
      
      # FIXME - clean up this xulrunnerlocator crap that takes up like half the class
      XULRunnerLocators = {:firefox => {}, :xulrunner => {}}
      XULRunnerLocators[:firefox][:unix] = [lambda { `which firefox-bin`}, lambda { `which firefox`}]
      XULRunnerLocators[:xulrunner][:unix] = [lambda { `which xulrunner-bin`}, lambda { `which xulrunner`}]
      
      # Linux uses the default UNIX locators
      XULRunnerLocators[:firefox][:linux] = XULRunnerLocators[:firefox][:unix]
      XULRunnerLocators[:xulrunner][:linux] = XULRunnerLocators[:xulrunner][:unix]
      
      # Darwin does some extra magic
      XULRunnerLocators[:firefox][:darwin] = XULRunnerLocators[:firefox][:unix] + [
        lambda do 
          applications = `osascript -e 'POSIX path of (path to applications folder)'`.strip
          firefox_bin = Pathname(applications) + "Firefox.app/Contents/MacOS/firefox-bin"
          firefox_bin.exist? ? firefox_bin.expand_path.to_s : ''
        end
      ]
      
      XULRunnerLocators[:xulrunner][:darwin] = XULRunnerLocators[:xulrunner][:unix] + [
        lambda do 
          library = `osascript -e 'POSIX path of (path to library folder)'`.strip
          xulrunner_bin = Pathname(library) + "Frameworks/XUL.framework/xulrunner-bin"
          xulrunner_bin.exist? ? xulrunner_bin.expand_path.to_s : ''
        end
      ]

      
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
        use_xulrunner ? :xulrunner : :firefox
      end
      
    private
    
      def launch_app(application_ini_path, args)
        xulrunner_path = find_xulrunner
        if xulrunner_path
          XPCOMCore::CommandParser.log("Launching XUL application using '#{xulrunner_path}' from '#{application_ini_path}'")
          set_env_and_launch(xulrunner_path, application_ini_path, args)
        else
          raise(XULRunnerNotFoundError, "A valid XULRunner executable could not be found.")
        end
      end
      
      def set_env_and_launch(xulrunner_bin, application_ini, args)
        ENV['XPCOMCORE'] = ENV['XPCOMCORE'] || XPCOMCore::BootstrapperLocation.to_s
        XPCOMCore::CommandParser.log("Using XPCOMCore bootstrapper at '#{ENV['XPCOMCORE']}'")
        exec(xulrunner_bin, *["-app", application_ini, "-no-remote", *args])
      end
      
      def find_xulrunner
        XULRunnerLocators[runner_type][CurrentPlatform].any? do |locator|
          location = locator.call.strip
          location.empty? ? nil : (break(location))
        end
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