require 'rake'
require 'xpcomcore-rubygem'
require 'uuidtools'

module XPCOMCore
  module Tasks
    class ApplicationTask
      IniLocation = "xpcomcore/app/application.ini"
      
      def initialize(task_name = "xpcomcore:update_xul_application")
        desc("Updates the embedded XUL application's application.ini file for release.")
        task(task_name) { self.invoke }
        # Adds this as a dependency to gemspec so it updates along with it.
        task(:gemspec => task_name)
      end
      
      def invoke
        @ini_file = Pathname(IniLocation)
        raise("The ini file at '#{ini_file}' doesn't exist or is not writable.") unless @ini_file.exist? && @ini_file.writable?
        @ini_file.open('r+') do |f|
          write_build_id(f)
          write_version(f)
        end
      end
    
    private
      
      def write_build_id(file)
        file.rewind
        contents = file.read
        file.truncate(0)
        build_id =  UUIDTools::UUID.random_create
        file.seek(0)
        file.write(contents.sub(/^BuildID=.*$/, "BuildID=#{build_id}"))
      end
      
      def write_version(file)
        file.rewind
        contents = file.read
        file.truncate(0)
        version = File.read('VERSION').strip
        file.seek(0)
        file.write(contents.sub(/^Version=.*$/, "Version=#{version}"))
      end
      
    end # ApplicationTask
  end   # Tasks
end     # XPCOMCore