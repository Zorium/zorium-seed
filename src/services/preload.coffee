z = require 'zorium'

StateService = require './state'

CACHE_KEY = 'PreloadService.cache'

class PreloadService
  set: ({url, opts}, val) ->
    cache = StateService.get(CACHE_KEY) or {}
    optsKey = JSON.stringify opts
    cache[url] ?= {}

    cache[url][optsKey] = val

    StateService.set CACHE_KEY, cache

  get: ({url, opts}) ->
    optsKey = JSON.stringify opts
    window?.PRELOAD_SERVICE?.CACHE[url]?[optsKey]

  remove: ({url, opts}) ->
    cache = StateService.get(CACHE_KEY) or {}
    optsKey = JSON.stringify opts

    delete cache[url]?[optsKey]
    delete window?.PRELOAD_SERVICE?.CACHE[url]?[optsKey]

    StateService.set CACHE_KEY, cache

  serializeToComponent: ->
    cache = StateService.get(CACHE_KEY) or {}

    z 'script',
      innerHTML: "
      window.PRELOAD_SERVICE = {};
      window.PRELOAD_SERVICE.CACHE = #{JSON.stringify cache};
      "


module.exports = new PreloadService()
