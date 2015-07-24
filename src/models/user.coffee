_ = require 'lodash'
Rx = require 'rx-lite'

config = require '../config'

module.exports = class User
  constructor: ({@cookieSubject, @proxy}) -> null
  login: =>
    @proxy config.API_URL + '/demo/users/me', {method: 'POST'}

  getMe: =>
    Rx.Observable.defer =>
      accessToken = @cookieSubject.getValue()[config.AUTH_COOKIE]
      (if accessToken
        @proxy config.API_URL + '/demo/users/me',
          headers:
            Authorization: "Token #{accessToken}"
        .catch (err) =>
          unless err.status is 401
            throw err

          @login()
      else
        @login()
      ).then (user) =>
        authCookies = {}
        authCookies[config.AUTH_COOKIE] = user.accessToken
        @cookieSubject.onNext _.defaults authCookies, @cookieSubject.getValue()
        return user
