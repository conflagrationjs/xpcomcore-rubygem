require "xpcomcore-rubygem/commands/generate/jeweler_builder_command"
require 'uuidtools'

module XPCOMCore
  class CommandParser
    class GenerateCommand
      
      class ApplicationCommand < JewelerBuilderCommand
        
        def initialize
          super('application', false) # Doesn't take subcommands
          self.short_desc = "Generates an application"
          self.options = CmdParse::OptionParserWrapper.new { |opt_parse| add_jeweler_opts(opt_parse) }
        end
  
      private
      
        def setup_project(gem_name, project_path)
          with_rakefile_in(project_path) do |rakefile|
            add_jsdoc_toolkit_doc_task(rakefile, :task_name => "doc:app", :doc_dir => "xpcomcore/app/doc", :doc_paths => %w[xpcomcore/app/chrome xpcomcore/app/components])
            add_xultestrunner_test_task(rakefile, :task_name => "test:app", :test_libs => %w[xpcomcore/app/chrome], :test_pattern => "xpcomcore/app/test/**/*_test.js")
          end
          copy_template_application(gem_name, project_path)
        end
        
        def copy_template_application(gem_name, project_path)
          template_vars = {'application.ini' => default_application_ini_values(gem_name),
                           'chrome.manifest' => default_chrome_manifest_values(gem_name),
                           'main_window.xul' => default_main_window_xul_values(gem_name),
                           'prefs.js'        => default_prefs_js_values(gem_name)}
                           
          copy_template_directory("application", project_path + "xpcomcore/app", template_vars)
        end

        def default_application_ini_values(gem_name)
          build_properties_version = XPCOMCore::BuildProperties['version']
          min_xpcomcore_version = build_properties_version.values_at('major', 'minor', 'patch').join('.')
          {:app_name => gem_name.capitalize,
           :app_version => "0.0.0",
           :build_id => UUIDTools::UUID.random_create.to_s,
           :app_id => "#{gem_name.capitalize}@CHANGEME.example.com",
           :app_vendor => ENV['USER'],
           :min_gecko_version => XPCOMCore::BuildProperties['gecko']['min_version'],
           :min_xpcomcore_version => min_xpcomcore_version}
        end
        
        def default_chrome_manifest_values(gem_name)
          {:default_chrome_id => gem_name}
        end
        
        def default_prefs_js_values(gem_name)
          {:default_chrome_id => gem_name}
        end
        
        def default_main_window_xul_values(gem_name)
          {:app_name => gem_name.capitalize}
        end
        
      end # ApplicationCommand
      
    end   # GenerateCommand
  end     # CommandParser
end       # XPCOMCore