require 'iniparse'
require 'plist'

module XPCOMCore
  module Building
    module StubAppHelpers
      class AppUpdater
        IconPath = "chrome/icons/default/default.png"
        IconConverter = "png2icns"
        
        def initialize(options)
          @xul_app_path = options[:xul_app_path]
          @stub_dir = options[:stub_dir]
        end
        
        def update
          app_ini = IniParse.parse((@xul_app_path + "application.ini").read)
          app_section = app_ini['App']
          check_for_and_set_app_dir(app_section['Name'])
          rewrite_plist(:name => app_section['Name'], :version => app_section['Version'], :id => app_section['ID'], :vendor => app_section['Vendor'])
          generate_icon(:name => app_section['Name'])
        end
        
      private
        
        def check_for_and_set_app_dir(app_name)
          app_dir = (@stub_dir + "#{app_name}.app")
          raise "Stub App dir for #{app_name} does not exist." unless app_dir.exist?
          @app_dir = app_dir
        end
                
        def rewrite_plist(options)
          existing_plist = Plist::parse_xml((@app_dir + "Contents/Info.plist").to_s)
          existing_plist['CFBundleGetInfoString'] = "%s %s © #{Date.today.year} %s" % options.values_at(:name, :version, :vendor)
          existing_plist['CFBundleIconFile'] = options[:name].downcase
          existing_plist['CFBundleIdentifier'] = appleize_id(options[:id])
          existing_plist['CFBundleName'] = options[:name]
          existing_plist['CFBundleShortVersionString'] = options[:version]
          existing_plist['CFBundleVersion'] = options[:version]
          existing_plist.save_plist((@app_dir + "Contents/Info.plist").to_s)
        end
        
        def appleize_id(mozilla_vendor)
          mozilla_vendor.sub('@', '.').split('.').reverse.collect {|p| p.downcase}.join('.')
        end
        
        def generate_icon(options)
          converter_installed = system("which", IconConverter)
          if converter_installed
            icon_file = @xul_app_path + IconPath
            return nil unless icon_file.exist?
            system(IconConverter, (@app_dir + "Contents/Resources" + "#{options[:name].downcase}.icns").expand_path.to_s, icon_file.expand_path.to_s)
          else
            puts "#{IconConverter} is not installed - install it to auto generate icons for Mac users."
          end
        end
        
      end # AppUpdater
    end   # StubAppHelpers
  end     # Building
end       # XPCOMCore