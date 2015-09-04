_ = require 'lodash'
Rx = require 'rx-lite'
log = require 'loga'

config = require '../config'

module.exports = class User
  constructor: ({@cookieSubject, @netox}) ->
    @validAccessTokens = new Rx.ReplaySubject(1)

    @loginAnon(@cookieSubject.getValue()[config.AUTH_COOKIE])
    .catch =>
      @loginAnon()
    .catch log.error

  loginAnon: (accessToken = null) =>
    @netox.fetch config.API_URL + '/demo/users/me',
      method: 'POST'
      isIdempotent: true
      headers:
        'Authorization': accessToken? and "Token #{accessToken}" or undefined
    .then (user) =>
      @validAccessTokens.onNext user.accessToken
      authCookies = {}
      authCookies[config.AUTH_COOKIE] = user.accessToken
      @cookieSubject.onNext \
        _.defaults authCookies, @cookieSubject.getValue()
      return user

  getMe: =>
    @validAccessTokens
    .flatMapLatest (accessToken) =>
      @netox.stream config.API_URL + '/demo/users/me',
        headers:
          Authorization: "Token #{accessToken}"
