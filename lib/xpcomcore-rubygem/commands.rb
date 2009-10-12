require 'cmdparse'
require 'xpcomcore-rubygem'
require 'pathname'

module XPCOMCore
  class CommandParser
    class << self
      attr_accessor :quiet
    end
    self.quiet = false
    
    @@commands = [CmdParse::HelpCommand, CmdParse::VersionCommand]
    
    def initialize
      @cmd = CmdParse::CommandParser.new(true, # handle exceptions gracefully
                                         true) # use partial command matching)
      @cmd.program_version = XPCOMCore::Version
      @cmd.options = CmdParse::OptionParserWrapper.new do |opt|
        opt.separator "Global options:"
        opt.on("-q", "--quiet", "Be quiet about what's happening", self.class.method(:quiet=))
      end
      add_commands
    end
    
    def parse
      @cmd.parse
    end
    
    def self.load_commands
      (XPCOMCore::GemRoot + "lib/xpcomcore-rubygem/commands").each_entry do |entry|
        next unless entry.extname == ".rb"
        require "xpcomcore-rubygem/commands/#{entry.basename}"
      end
    end
    
    def self.add_command(cmd_class)
      @@commands.push(cmd_class)
    end

    def self.log(msg)
      return nil if quiet
      puts msg
    end
    
  private
  
    def add_commands
      @@commands.each { |cmd_class| @cmd.add_command(cmd_class.new) }
    end
    
  end # CommandParser
end   # XPCOMCore

XPCOMCore::CommandParser.load_commands