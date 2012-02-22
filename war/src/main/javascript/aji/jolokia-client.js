/*
 * Copyright 2009-2011 Roland Huss
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


/**
 * Single entry point for communication with the Jolokia Backend.
 * This client is responsible for
 * <ul>
 *   <li> Periodically calling the Jolokia Backend and notifying registered
 *        listeners.</li>
 *   <li> Fetching Meta data from the Jolokia Backend</li>
 * </ul>
 */

define(["jquery","jolokia/jolokia-simple"], function ($,Jolokia) {
    return (function ($) {

        // Constructor requiring as single argument the jolokia
        // client.
        function _meta(url) {
            // For accessing the server
            this.j4p = new Jolokia(url);

            // Naming cache
            this.nameCache = null;

            // Collections of MBean Meta information
            this.mbeansMeta = new Object();

            // List of registered requests along with the callback
            this.requests = [];

            // Interval between two refreshes, in seconds
            this.pollPeriod = 5 * 60;

            // Id of timer
            this.timerId = null;

            // State of this client: "paused", "running"
            this.state = "paused";

            this.registerRequest = function (callback, request) {
                if (arguments.length < 2) {
                    throw "At a least a request must be provided";
                }
                var success_cb, error_cb;
                if (typeof callback === 'object') {
                    success_cb = callback.success;
                    error_cb = callback.error;
                } else if (typeof callback == 'function') {
                    success_cb = callback;
                    error_cb = null;
                } else {
                    throw "First argument must be either a callback func " +
                          "or an object with 'success' and 'error' attrs";
                }
                var handle = this.requests.length;
                this.requests[handle] = {
                    success:success_cb,
                    error:error_cb,
                    requests:Array.prototype.slice.call(arguments, 1)
                };
                return handle;
            };

            this.unregisterRequest = function (handle) {
                this.requests[handle] = null;
            };

            this.compressRequests = function () {
                this.requests = _.filter(this.requests, function (req) {
                    return req != null;
                });
            };

            this.callJolokia = function () {
                var success_cbs = [];
                var error_cbs = [];
                var requests = [];
                _.each(this.requests, function (job) {
                    if (job != null) {
                        _.each(job.requests, function (req) {
                            requests.push(req);
                            success_cbs.push(job.success);
                            error_cbs.push(job.error);
                        })
                    }
                });
                this.j4p.request(requests, {
                    success:function (resp, i) {
                        success_cbs[i].apply(this, resp);
                    },
                    error:function (resp, i) {
                        if (error_cbs[i] != null) {
                            error_cbs[i].apply(this, resp);
                        }
                    }
                });
            };

            // Start poller
            this.start = function (pollInterval) {
                var interval = pollInterval || this.pollPeriod;
                if (this.running()) {
                    if (interval == this.pollPeriod) {
                        return;
                    }
                    this.stop();
                }
                this.timerId = setInterval(this.callJolokia, this.pollPeriod);
                this.state = "running";
            };


            // Stop poller;
            this.stop = function () {
                if (!this.running()) {
                    return;
                }
                clearInterval(this.timerId);
                this.timerId = null;
                this.state = "stopped";
            };

            this.running = function () {
                return this.state.equals("running");
            };

            // Get names. force == true -> refresh cache
            this.filterNames = function (term, force) {
                checkCache(this, force);
                var regexp = new RegExp(term, "i");
                return _.select(this.nameCache, function (elem) {
                    return regexp.test(elem);
                })
            };

            // Get the MBeanInfo for an MBean with the given name
            this.getMBeanInfo = function (name, force) {
                var meta = this.mbeansMeta[name];
                if (!meta || force) {
                    meta = loadMeta(this.j4p, name);
                    this.mbeansMeta[meta.name] = meta;
                }
                return meta;
            };
        }

        return new _meta("..");

        // =============================================================================
        // Private functions:

        // load all MBean names from the target and return it sorted
        function loadNames(j4p) {
            var tree = j4p.list(null, 2);
            var names = [];
            $.each(tree, function (domain, value) {
                $.each(value, function (props, eins) {
                    names.push(domain + ":" + props);
                })
            });
            return names.sort();
        }

        // Check local that local cache name exists and
        // load all MBean names from the server if not
        // (or if 'force' is set)
        function checkCache(store, force) {
            if (!store.nameCache || force) {
                store.nameCache = loadNames(store.j4p);
            }
        }

        // Load MBean meta data from the server
        function loadMeta(j4p, name) {
            // Simplistic approach for converting a MBean name to a path. Should
            // take escaping into account
            var path = name.split(":").join("/");
            var meta = j4p.list(path);
            return $.extend(meta, { name:name});
        }

    })(jQuery);
});


