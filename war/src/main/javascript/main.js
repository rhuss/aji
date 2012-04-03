/*
 * Copyright 2009-2012 Roland Huss
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

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
 ["backbone","aji/TemplateManager","aji/AppRouter","domReady!"],
 function(Backbone,TemplateManager,AppRouter) {
     TemplateManager.loadTemplates(['header','navigator'],
             function () {
                 app = new AppRouter();
                 Backbone.history.start();
             });

 });