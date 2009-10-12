require "xpcomcore-rubygem/commands/generate/jeweler_builder_command"

module XPCOMCore
  class CommandParser
    class GenerateCommand

      class LibraryCommand < JewelerBuilderCommand
  
        def initialize
          super('library', false) # Doesn't take subcommands
          self.short_desc = "Generates a library"
          self.options = CmdParse::OptionParserWrapper.new { |opt_parse| add_jeweler_opts(opt_parse) }
        end
      
      private
      
        def setup_project(gem_name, project_path)
        
        end
        
      end # LibraryCommand

    end   # GenerateCommand
  end     # CommandParser
end       # XPCOMCore