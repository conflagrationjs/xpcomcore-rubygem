require 'pathname'

module XPCOMCore
  root_dir = Pathname(__FILE__).parent.parent
  Version = (root_dir + "VERSION").read.strip
  BootstrapperLocation = (root_dir + "xpcomcore/bootstrapper.js").expand_path
end