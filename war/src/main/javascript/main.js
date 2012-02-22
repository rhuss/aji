/**
 * Main Loader setting up Aji
 *
 */

// Load up jQuery as soon as possible, since it should be available as 'jquery' to any dependency
curl({
 paths: {
     "jquery" : "support/jquery/jquery",
     "underscore": "support/underscore",
     "backbone": "support/backbone",
     "jolokia": "jolokia/jolokia",
     "jolokia-simple": "jolokia/jolokia-simple"
 }},
 ["aji/JolokiaClient","aji/mbean/MBeanSpecModelFactory","aji/mbean/MBeanSidebarView","domReady!"],
 function(client,MBeanSpecModelFactory,view) {
     console.log(client.getMBeanInfo("java.lang:type=Memory"));
     console.log(client.filterNames(".*"));
     var attr = MBeanSpecModelFactory.newAttributeRequest({
                 mbean: "java.lang:type=Memory",
                 attribute: "HeapMemoryUsage",
                 path: "used"
             });
     console.log(attr.toJolokiaRequest());
 });