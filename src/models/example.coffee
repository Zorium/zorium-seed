Rx = require 'rx-lite'

config = require '../config'
RequestService = require '../services/request'

PATH = config.API_URL

class Example
  get: do ->
    stream = Rx.Observable.defer ->
      Rx.Observable.fromPromise \
        RequestService PATH + '/demo'
    -> stream


module.exports = new Example()
