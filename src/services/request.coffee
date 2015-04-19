request = require 'clay-request'

PreloadService = require './preload'

Promise = if window?
  window.Promise
else
  # Avoid webpack include
  _Promise = 'bluebird'
  require _Promise

module.exports = (url, opts) ->
  key = url + '://:' + JSON.stringify opts

  result = if window?
    PreloadService.pick key
  else
    null

  if result
    Promise.resolve result
  else
    request url, opts
    .then (res) ->
      PreloadService.set key, res
      return res
