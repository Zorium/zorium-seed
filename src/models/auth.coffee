_ = require 'lodash'
Rx = require 'rx-lite'
log = require 'loga'

config = require '../config'

module.exports = class Auth
  constructor: ({@netox, cookieSubject}) ->
    initialAuthPromise = null

    @accessTokenStreams = new Rx.ReplaySubject(1)
    @accessTokenStreams.onNext Rx.Observable.defer =>
      unless initialAuthPromise?
        cookieAccessToken = cookieSubject.getValue()[config.AUTH_COOKIE]

        initialAuthPromise = (if cookieAccessToken?
          @netox.stream config.API_URL + '/demo/users/me',
            headers:
              Authorization: "Token #{cookieAccessToken}"
          .take(1).toPromise()
          .catch =>
            @netox.fetch config.API_URL + '/demo/users/me',
              method: 'POST'
              isIdempotent: true
        else
          @netox.fetch config.API_URL + '/demo/users/me',
            method: 'POST'
            isIdempotent: true
        ).then ({accessToken}) -> accessToken
      return initialAuthPromise

    @accessTokens = @accessTokenStreams.switch()
    .doOnNext (accessToken) ->
      cookies = {}
      cookies[config.AUTH_COOKIE] = accessToken
      cookieSubject.onNext \
        _.defaults cookies, cookieSubject.getValue()

  stream: (url, opts) =>
    @accessTokens
    .flatMapLatest (accessToken) =>
      @netox.stream url, _.merge {
        headers:
          Authorization: "Token #{accessToken}"
      }, opts

  fetch: (url, opts) =>
    @accessTokens.take(1).toPromise()
    .then (accessToken) =>
      @netox.fetch url, _.merge {
        headers:
          Authorization: "Token #{accessToken}"
      }, opts

  loginAnon: =>
    @fetch config.API_URL + '/demo/users/me',
      method: 'POST'
      isIdempotent: true
    .then (user) =>
      @accessTokenStreams.onNext Rx.Observable.just user.accessToken
      return user
