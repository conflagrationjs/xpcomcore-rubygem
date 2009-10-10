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
      var xpcomcoreBootstrapper = env.exists('XPCOMCORE_BOOTSTRAP') && env.get('XPCOMCORE_BOOTSTRAP');
      if (xpcomcoreBootstrapper) { 
        dump("\n\nLoading XPCOMCore Bootstrapper from " + xpcomcoreBootstrapper + ".\n\n");
        Components.utils.import("file://" + xpcomcoreBootstrapper);
        dump("\n\nXPCOMCore bootstrapped.\n\n");
      } else {
        dump("\n\nNot loading XPCOMCore Bootstrapper.\n\n");
      }      
    }
  }
  
};

NSGetModule = function(compMgr, fileSpec) { return XPCOMUtils.generateModule([XPCOMCoreBootstrapper]); };