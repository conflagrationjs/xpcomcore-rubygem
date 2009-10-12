Components.utils.import("resource://gre/modules/XPCOMUtils.jsm");

// Singleton time
var XPCOMCoreBootstrapper = function() {
  if (arguments.callee.__singletonInstance__) { return arguments.callee.__singletonInstance__; };
  arguments.callee.__singletonInstance__ = this;
};

XPCOMCoreBootstrapper.prototype = {
  bootstrapped: false,
  classDescription: "XPCOMCore Bootstrapper Component",
  contractID: "@conflagrationjs.org/xpcomcore/bootstrapper;1",
  classID: Components.ID("{5412c380-b3b2-11de-8a39-0800200c9a66}"),
  QueryInterface: XPCOMUtils.generateQI([Components.interfaces.nsIObserver]),
  _xpcom_categories: [{category: "xpcom-startup"}],
  
  observe: function(subject, topic, data) {
    if (topic != "xpcom-startup") { return false; }
    if (this.bootstrapped) {
      dump("\n\nXPCOMCore already bootstrapped.\n\n");
    } else {      
      var env = Components.classes["@mozilla.org/process/environment;1"].getService(Components.interfaces.nsIEnvironment);
      var xpcomcoreBootstrapper = env.exists('XPCOMCORE') && env.get('XPCOMCORE');
      if (xpcomcoreBootstrapper) { 
        try {
          var iniFile = Components.classes["@mozilla.org/file/directory_service;1"].getService(Components.interfaces.nsIProperties).get("XCurProcD", Components.interfaces.nsIFile);
          iniFile.append("application.ini");
          iniFile.QueryInterface(Components.interfaces.nsILocalFile);

          var iniParser = Components.classes["@mozilla.org/xpcom/ini-parser-factory;1"].getService(Components.interfaces.nsIINIParserFactory).createINIParser(iniFile);
          var xpcomCoreMinVersion = iniParser.getString('XPCOMCore', 'MinVersion');
        
          dump("\n\nLoading XPCOMCore Bootstrapper from " + xpcomcoreBootstrapper + ".\n\n");
          Components.utils.import("file://" + xpcomcoreBootstrapper);          
          var versionComparator = Components.classes["@mozilla.org/xpcom/version-comparator;1"].createInstance(Components.interfaces.nsIVersionComparator);
          
          if (versionComparator.compare(XPCOMCoreConfig.getProperty('version'), xpcomCoreMinVersion) < 0) {
            throw("XPCOMCore version " + xpcomCoreMinVersion + " is required but we were bootstrapped with " + XPCOMCoreConfig.getProperty('version') + ".");
          }
          
          dump("\n\nXPCOMCore bootstrapped with version " + XPCOMCoreConfig.getProperty('version') + ".\n\n");
        } catch (e) {
          dump("\nException caught. Quitting.\n" + e + "\n");
          var appStartup = Components.classes['@mozilla.org/toolkit/app-startup;1'].getService(Components.interfaces.nsIAppStartup);
          appStartup.quit(Components.interfaces.nsIAppStartup.eForceQuit);
        }
      } else {
        dump("\n\nNot loading XPCOMCore Bootstrapper.\n\n");
      }      
    }
  }
  
};

NSGetModule = function(compMgr, fileSpec) { return XPCOMUtils.generateModule([XPCOMCoreBootstrapper]); };