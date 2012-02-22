###
 Copyright 2009-2011 Roland Huss

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
    nameCache: null

    # Collections of MBean Meta information
    mbeansMeta: {}

    # List of registered requests along with the callback
    requests: []

    # Interval between two refreshes, in seconds
    pollPeriod : 5 * 60

    # Id of timer
    timerId : null

    # State of this client: "paused", "running"
    state : "paused"

    # Constructor requiring as single argument the jolokia
    # client.
    constructor: (url) -> @j4p = new Jolokia(url)

    registerRequest : (callback, request...) ->
      throw  "At a least one request must be provided" if arguments.length < 2
      if (typeof callback is 'object')
        success_cb = callback.success
        error_cb = callback.error
      else if (typeof callback is 'function')
        success_cb = callback
        error_cb = null
      else
        throw "First argument must be either a callback func " +
              "or an object with 'success' and 'error' attrs"

      handle = @requests.length
      @requests[handle] =
        success : success_cb
        error : error_cb
        requests : arguments[1..]
      handle

    unregisterRequest: (handle) -> @requests[handle] = null

    compressRequests: -> @requests = _.filter(@requests, (req) -> req != null)

    callJolokia: ->
      success_cbs = []
      error_cbs = []
      requests = []
      for job in @requests
        for req in job?.requests
          requests.push(req)
          success_cbs.push(job.success)
          error_cbs.push(job.error)

      opts =
        success: (resp, i) -> success_cbs[i].apply(this, resp)
        error: (resp, i) -> error_cbs[i].apply(this, resp) if error_cbs[i] != null

      @j4p.request(requests, opts)

    # Start poller
    start: (pollInterval) ->
      interval = pollInterval or @pollPeriod
      if (@running())
        return if interval is @pollPeriod
        @stop()

      @timerId = setInterval(@callJolokia, @pollPeriod)
      @state = "running"

    # Stop poller;
    stop: ->
      return if not @running()
      clearInterval(@timerId)
      @timerId = null
      @state = "stopped"

    running: -> @state is "running"

    # Get names. force == true -> refresh cache
    filterNames: (term, force) ->
      checkCache(this, force)
      regexp = new RegExp(term, "i")
      _.filter(@nameCache, (elem) -> regexp.test(elem))

    # Get the MBeanInfo for an MBean with the given name
    getMBeanInfo : (name, force) ->
      meta = @mbeansMeta[name]
      if (not meta or force)
        meta = loadMeta(@j4p, name)
        @mbeansMeta[meta.name] = meta
      meta

  # =============================================================================
  # Private functions:

  # load all MBean names from the target and return it sorted
  loadNames = (j4p) ->
    tree = j4p.list(null, 2)
    names = [];
    for domain, value of tree
      for props of value
        names.push(domain + ":" + props)
    names.sort()

  # Check local that local cache name exists and
  # load all MBean names from the server if not
  # (or if 'force' is set)
  checkCache = (store, force) ->
    store.nameCache = loadNames(store.j4p) if !store.nameCache or force

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

