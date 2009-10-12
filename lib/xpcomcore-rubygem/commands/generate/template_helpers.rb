require 'erb'
require 'fileutils'

# FIXME - clean this ugly guy up
module XPCOMCore
  class CommandParser
    class GenerateCommand

      module TemplateHelpers
        TemplateDir = XPCOMCore::GemRoot + "templates"
        class EvalContext
          def initialize(ivars)
            ivars.each {|k,v| instance_variable_set("@#{k}", v)}
          end
          
          def get_binding
            binding
          end
        end # EvalContext
        
        def eval_template(path, vars)
          context = EvalContext.new(vars)
          template = ERB.new((TemplateDir + path).read)
          template.result(context.get_binding)
        end
        
        def copy_template_directory(dir_name, dest, template_vars)
          template_dir = (TemplateDir + dir_name).expand_path
          dest.mkpath
          Pathname.glob("#{template_dir}/**/*").each do |dir_entry|
            handle_entry_creation(template_dir, dir_entry, dest, template_vars)
          end
        end
        
        def handle_entry_creation(template_dir, dir_entry, dest_dir, template_vars)
          relative_path = dir_entry.relative_path_from(template_dir)
          if dir_entry.directory?
            mkpath(dest_dir + relative_path)
          else
            handle_file(dir_entry, (dest_dir + relative_path), template_vars)
          end
        end
        
        def handle_file(entry, dest, template_vars)
          if entry.extname == ".erb"
            copy_template(entry, dest, template_vars)
          else
            copy_file(entry, dest)
          end
        end
        
        def mkpath(path)
          puts "Creating #{path}"
          path.mkpath
        end
        
        def copy_template(entry, dest, template_vars)
          real_dest = Pathname(dest.expand_path.to_s.sub(/#{dest.extname}$/, ""))
          puts "Creating #{real_dest}"
          vars = determine_template_vars(real_dest, template_vars)
          real_dest.open('w') { |f| f << eval_template(entry, vars) }
        end
        
        def copy_file(entry, dest)
          puts "Creating #{dest.expand_path}"
          FileUtils.cp(entry.expand_path.to_s, dest.expand_path.to_s)
        end
        
        def determine_template_vars(dest, template_vars)
          template_vars.detect do |path,values|
            dest.to_s =~ /#{Regexp.escape(path)}$/
          end.last
        end
      end # TemplateHelpers
      
    end   # GenerateCommand
  end     # CommandParser
end       # XPCOMCore