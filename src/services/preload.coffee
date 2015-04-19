z = require 'zorium'

class PreloadService
  constructor: ->
    @cache = window?.PRELOAD_SERVICE?.CACHE or {}

  set: (key, val) ->
    @cache[key] = val

  pick: (key) ->
    val = @cache[key]
    delete @cache[key]
    return val

  serializeToComponent: ->
    z 'script',
      innerHTML: "
      window.PRELOAD_SERVICE = {};
      window.PRELOAD_SERVICE.CACHE = #{JSON.stringify @cache};
      "


module.exports = new PreloadService()
