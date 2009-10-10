require 'xpcomcore-rubygem/commands'

module XPCOMCore
  class CommandParser
    class GenerateCommand < CmdParse::Command
      
      def initialize
        super('generate', true) # Doesn't take subcommands
        self.short_desc = "Generates an XPCOMCore based XUL application, packaged in a RubyGem."
      end

    end # GenerateCommand
  end   # CommandParser
end     # XPCOMCore

XPCOMCore::CommandParser.add_command(XPCOMCore::CommandParser::GenerateCommand)