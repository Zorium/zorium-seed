request = require 'clay-request'
z = require 'zorium'
_ = require 'lodash'
Rx = require 'rx-lite'

PreloadService = require './preload'
StateService = require './state'
config = require '../config'

CACHE_STATE_KEY = 'RequestService.cache'

class RequestService
  getStream: (url, opts = {}) ->
    cache = StateService.get(CACHE_STATE_KEY) or {}
    optsKey = JSON.stringify opts

    cache[url] ?= {}

    if cache[url][optsKey]
      return cache[url][optsKey].stream

    resultStreamSubject = new Rx.ReplaySubject(1)

    resultStream = Rx.Observable.defer ->
      preloaded = PreloadService.get {url, opts}
      if preloaded
        return Rx.Observable.return preloaded
      else
        request url, opts
        .then (res) ->
          if not window?
            PreloadService.set {url, opts}, res
          return res

    .shareReplay(1)

    resultStreamSubject.onNext resultStream

    cache[url][optsKey] = {
      stream: resultStreamSubject.switch()
      subject: resultStreamSubject
      url
      opts
    }

    StateService.set CACHE_STATE_KEY, cache

    return cache[url][optsKey].stream

  clearCache: ->
    cache = StateService.get(CACHE_STATE_KEY) or {}

    _.forEach cache, (urlCache) ->
      _.forEach urlCache, ({subject, url, opts}) ->
        requestStream = Rx.Observable.defer ->
          request url, opts
          .then (res) ->
            PreloadService.set {url, opts}, res
            return res
        .shareReplay(1)

        subject.onNext requestStream
        return

    StateService.set(CACHE_STATE_KEY,  {})

  post: (url, opts = {}) =>
    opts = _.defaults opts, {
      method: 'POST'
    }

    request url, opts
    .then (res) =>
      @clearCache()
      return res

  put: (url, opts = {}) =>
    opts = _.defaults opts, {
      method: 'PUT'
    }
    request url, opts
    .then (res) =>
      @clearCache()
      return res

module.exports = new RequestService()
