require 'xpcomcore-rubygem/commands'

module XPCOMCore
  class CommandParser
    class GenerateCommand < CmdParse::Command
      
      class ApplicationCommand < CmdParse::Command
        def initialize
          super('application', false) # Doesn't take subcommands
          self.short_desc = "Generates an application"
        end
        
      end # ApplicationCommand
      
      class ExtensionCommand < CmdParse::Command
        
        def initialize
          super('extension', false) # Doesn't take subcommands
          self.short_desc = "Generates an extension"
        end
        
      end # ExtensionCommand
      
      def initialize
        super('generate', true,  # Takes subcommands
                          true)  # Uses partial command matching
        self.short_desc = "Generates an XPCOMCore based XUL application or XULRunner extension"
        [ApplicationCommand, ExtensionCommand].each { |k| add_command(k.new) }
      end

    end # GenerateCommand
  end   # CommandParser
end     # XPCOMCore

XPCOMCore::CommandParser.add_command(XPCOMCore::CommandParser::GenerateCommand)