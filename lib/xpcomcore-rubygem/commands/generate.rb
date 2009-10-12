require 'xpcomcore-rubygem/commands'

module XPCOMCore
  class CommandParser
    class GenerateCommand < CmdParse::Command
      class GenerationError < CmdParse::ParseError
        reason "An error occured trying to generate your application"
      end

      def initialize
        super('generate', true,  # Takes subcommands
                          true)  # Uses partial command matching
        self.short_desc = "Generates an XPCOMCore based XUL application or library packaged in a RubyGem."
        [ApplicationCommand, LibraryCommand].each { |k| add_command(k.new) }
      end

    end # GenerateCommand
  end   # CommandParser
end     # XPCOMCore

XPCOMCore::CommandParser.add_command(XPCOMCore::CommandParser::GenerateCommand)
require "xpcomcore-rubygem/commands/generate/application"
require "xpcomcore-rubygem/commands/generate/library"