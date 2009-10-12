require 'pathname'

module XPCOMCore
  GemRoot = Pathname(__FILE__).parent.parent
  Version = (GemRoot + "VERSION").read.strip
  BootstrapperLocation = (GemRoot + "xpcomcore/bootstrapper.js").expand_path
  BuildProperties = YAML.load_file((GemRoot + "xpcomcore/build_properties.yml").to_s)
  
end