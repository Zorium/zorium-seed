_ = require 'lodash'
Rx = require 'rx-lite'

config = require '../config'

module.exports = class Auth
  constructor: ({@exoid, cookieSubject}) ->
    initPromise = null
    @waitValidAuthCookie = Rx.Observable.defer =>
      if initPromise?
        return initPromise
      return initPromise = cookieSubject.take(1).toPromise()
      .then (currentCookies) =>
        (if currentCookies[config.AUTH_COOKIE]?
          @exoid.getCached 'users.getMe'
          .then (user) =>
            if user?
              return {accessToken: currentCookies[config.AUTH_COOKIE]}
            @exoid.call 'users.getMe'
            .then ->
              return {accessToken: currentCookies[config.AUTH_COOKIE]}
          .catch =>
            cookieSubject.onNext _.defaults {
              "#{config.AUTH_COOKIE}": null
            }, currentCookies
            @exoid.call 'auth.login'
        else
          @exoid.call 'auth.login')
        .then ({accessToken}) ->
          cookieSubject.onNext _.defaults {
            "#{config.AUTH_COOKIE}": accessToken
          }, currentCookies

  stream: (path, body) =>
    @waitValidAuthCookie
    .flatMapLatest =>
      @exoid.stream path, body

  call: (path, body) =>
    @waitValidAuthCookie.take(1).toPromise()
    .then =>
      @exoid.call path, body
