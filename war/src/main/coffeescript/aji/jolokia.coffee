###
 Copyright 2009-2012 Roland Huss

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
###


###
 Single entry point for communication with the Jolokia Backend.
 This client is responsible for

 * Periodically calling the Jolokia Backend and notifying registered
   listeners.
 * Fetching Meta data from the Jolokia Backend
###

define(["jolokia-simple","underscore"], (Jolokia,_) ->

  class JolokiaClient

    # Naming cache
    mbeanCache: null

    # Collections of MBean Meta information
    mbeansMeta: {}

    # List of registered requests along with the callback
    requests: []

    # Interval between two refreshes, in seconds
    pollPeriod : 5 * 60

    # Constructor requiring as single argument the jolokia
    # client.
    constructor: (url) -> @j4p = new Jolokia(url)

    # Register a request which gets polled periodically
    register : (callback, request...) ->
      throw  "At a least one request must be provided" if arguments.length < 2
      @j4p.register.apply(callback,arguments[1..])

    # Unregister a request
    unregister : (handle) ->
      @j4p.unregister(handle)

    # Poller lifecycle methods
    start : (pollInterval) ->
      @j4p.start(pollInterval or @pollPeriod)

    stop : ->
      @j4p.stop()

    isRunning : ->
      @j4p.isRunning()

    mBeans : (force) ->
      @mbeanCache = @j4p.list(null, {maxDepth : 2}) if !@mbeanCache or force
      @mbeanCache

    mBeanNames : (force) ->
      names = []
      for domain, value of @mBeans(force)
        for props of value
          names.push(domain + ":" + props)
      names.sort()

    filterNames : (term, force) ->
      regexp = new RegExp(term, "i")
      _.filter(@mBeanNames(force), (elem) -> regexp.test(elem))

    # Get the MBeanInfo for an MBean with the given name
    getMBeanInfo : (name, force) ->
      meta = @mbeansMeta[name]
      if (not meta or force)
        meta = loadMeta(@j4p, name)
        @mbeansMeta[meta.name] = meta
      meta

  # =============================================================================
  # Private functions:

  # Load MBean meta data from the server
  loadMeta = (j4p, name) ->
    # Simplistic approach for converting a MBean name to a path. Should
    # take escaping into account
    path = name.split(":").join("/")
    meta = j4p.list(path)
    _.extend(meta, {name:name})
    meta

  # Create and return singleton
  new JolokiaClient("..")
)

