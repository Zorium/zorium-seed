_ = require 'lodash'
Rx = require 'rx-lite'
request = require 'clay-request'

Example = require './example'
User = require './user'

Promise = if window?
  window.Promise
else
  # TODO: remove once v8 is updated
  # Avoid webpack include
  bluebird = 'bluebird'
  require bluebird

PROXY_CACHE_KEY = 'ZORIUM_PROXY_CACHE'

isGetRequest = (opts) ->
  not opts.method or opts.method.toLowerCase() is 'get'

module.exports = class Model
  constructor: ({cookieSubject, serverHeaders}) ->
    proxyCache = new Rx.BehaviorSubject(window?[PROXY_CACHE_KEY] or {})

    proxy = (url, opts = {}) ->
      cacheKey = JSON.stringify(opts) + '__z__' + url
      cached = proxyCache.getValue()[cacheKey]

      if not isGetRequest(opts)
        proxyCache.onNext {}
      else if cached
        return Promise.resolve cached

      proxyOpts = if serverHeaders
        _.merge {
          headers:
            userAgent: serverHeaders['user-agent']
            acceptLanguage: serverHeaders['accept-language']
        }, opts
      else
        opts

      request url, proxyOpts
      .then (res) ->
        if isGetRequest(opts)
          entry = {}
          entry[cacheKey] = res
          proxyCache.onNext _.defaults entry, proxyCache.getValue()
        return res

    @getProxyCacheKey = -> PROXY_CACHE_KEY
    @getProxyCache = -> proxyCache
    @example = new Example()
    @user = new User({cookieSubject, proxy})
