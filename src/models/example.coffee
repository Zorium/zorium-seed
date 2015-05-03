Rx = require 'rx-lite'

config = require '../config'
RequestService = require '../services/request'

PATH = config.API_URL

class Example
  get: ->
    RequestService.getStream PATH + '/demo'


module.exports = new Example()
