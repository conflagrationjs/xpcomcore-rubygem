var env = Components.classes["@mozilla.org/process/environment;1"].getService(Components.interfaces.nsIEnvironment);
var xpcomcoreBootstrapper = env.exists('XPCOMCORE_BOOTSTRAP') && env.get('XPCOMCORE_BOOTSTRAP');
if (xpcomcoreBootstrapper) { Components.utils.import("file://" + xpcomcoreBootstrapper); }