_ = require 'lodash'
Exoid = require 'exoid'
request = require 'clay-request'

Auth = require './auth'
User = require './user'
Example = require './example'
config = require '../config'

SERIALIZATION_KEY = 'ZORIUM_MODEL'
SERIALIZATION_EXPIRE_TIME_MS = 1000 * 10 # 10 seconds

module.exports = class Model
  constructor: ({cookieSubject, serverHeaders}) ->
    serverHeaders ?= {}

    # TODO: ugly
    serialization = window?[SERIALIZATION_KEY] or {}
    isExpired = if serialization.expires?
      # Because of potential clock skew we check around the value
      delta = Math.abs(Date.now() - serialization.expires)
      delta > SERIALIZATION_EXPIRE_TIME_MS
    else
      true
    cache = if isExpired then {} else serialization
    @isFromCache = not _.isEmpty cache

    accessToken = cookieSubject.map (cookies) ->
      cookies[config.AUTH_COOKIE]

    # TODO: ugly
    proxy = (url, opts) ->
      accessToken.take(1).toPromise()
      .then (accessToken) ->
        proxyHeaders =  _.pick serverHeaders, [
          'cookie'
          'user-agent'
          'accept-language'
          'x-forwarded-for'
        ]
        request url, _.merge {
          qs: if accessToken? then {accessToken} else {}
          headers: _.merge {
            # Avoid CORS preflight
            'Content-Type': 'text/plain'
          }, proxyHeaders
        }, opts

    @exoid = new Exoid
      api: config.API_URL + '/exoid'
      fetch: proxy
      cache: cache.exoid

    @auth = new Auth({@exoid, cookieSubject})
    @user = new User({@auth})
    @example = new Example({@auth})

  wasCached: => @isFromCache

  getSerializationStream: =>
    # TODO: ugly
    @exoid.getCacheStream()
    .map (exoidCache) ->
      string = JSON.stringify {
        exoid: exoidCache
        expires: Date.now() + SERIALIZATION_EXPIRE_TIME_MS
      }
      "window['#{SERIALIZATION_KEY}']=#{string};"
