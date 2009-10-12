Components.utils.import("resource://gre/modules/XPCOMUtils.jsm");

// Singleton time
var XPCOMCoreBootstrapper = function() {
  if (arguments.callee.__singletonInstance__) { return arguments.callee.__singletonInstance__; };
  arguments.callee.__singletonInstance__ = this;
};

XPCOMCoreBootstrapper.prototype = {
  bootstrapped: false,
  xpcomcoreEnvVar: 'XPCOMCORE',
  
  classDescription: "XPCOMCore Bootstrapper Component",
  contractID: "@conflagrationjs.org/xpcomcore/bootstrapper;1",
  classID: Components.ID("{5412c380-b3b2-11de-8a39-0800200c9a66}"),
  QueryInterface: XPCOMUtils.generateQI([Components.interfaces.nsIObserver]),
  _xpcom_categories: [{category: "xpcom-startup"}],
  
  observe: function(subject, topic, data) {
    if (topic != "xpcom-startup") { return false; }
    if (this.bootstrapped) { this.puts("XPCOMCore already bootstrapped."); return true; }
    try {
      var xpcomcoreBootstrapper = this.getBootstrapper();
      if (!xpcomcoreBootstrapper) { throw("No bootstrapper was found. Are you sure " + this.xpcomcoreEnvVar + " is set in your environment?"); }
          
      this.puts("Loading XPCOMCore Bootstrapper from " + xpcomcoreBootstrapper);
      Components.utils.import("file://" + xpcomcoreBootstrapper);
      this.checkVersion();
      this.puts("XPCOMCore bootstrapped with version " + XPCOMCoreConfig.getProperty('version'));
    } catch (e) {
      this.puts("Exception caught. Quitting.\n" + e);
      this.forceQuit();
    }
  },
  
  getBootstrapper: function() {
    var env = Components.classes["@mozilla.org/process/environment;1"].getService(Components.interfaces.nsIEnvironment);
    return env.exists(this.xpcomcoreEnvVar) && env.get(this.xpcomcoreEnvVar);
  },
  
  getMinXPCOMCoreVersion: function() {
    var iniFile = Components.classes["@mozilla.org/file/directory_service;1"].getService(Components.interfaces.nsIProperties).get("XCurProcD", Components.interfaces.nsIFile);
    iniFile.append("application.ini");
    iniFile.QueryInterface(Components.interfaces.nsILocalFile);

    var iniParser = Components.classes["@mozilla.org/xpcom/ini-parser-factory;1"].getService(Components.interfaces.nsIINIParserFactory).createINIParser(iniFile);
    return iniParser.getString('XPCOMCore', 'MinVersion');
  },
  
  checkVersion: function() {
    var xpcomCoreMinVersion = this.getMinXPCOMCoreVersion();
    var versionComparator = Components.classes["@mozilla.org/xpcom/version-comparator;1"].createInstance(Components.interfaces.nsIVersionComparator);
    
    if (versionComparator.compare(XPCOMCoreConfig.getProperty('version'), xpcomCoreMinVersion) < 0) {
      throw("XPCOMCore version " + xpcomCoreMinVersion + " is required but we were bootstrapped with " + XPCOMCoreConfig.getProperty('version') + ".");
    }
  },
  
  forceQuit: function() {
    var appStartup = Components.classes['@mozilla.org/toolkit/app-startup;1'].getService(Components.interfaces.nsIAppStartup);
    appStartup.quit(Components.interfaces.nsIAppStartup.eForceQuit);
  },
  
  puts: function(str) {
    dump(str + "\n");
  }
  
};

NSGetModule = function(compMgr, fileSpec) { return XPCOMUtils.generateModule([XPCOMCoreBootstrapper]); };