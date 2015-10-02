_ = require 'lodash'
Rx = require 'rx-lite'
log = require 'loga'

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
              return user
            @exoid.call 'users.getMe'
          .catch =>
            cookieSubject.onNext _.defaults {
              "#{config.AUTH_COOKIE}": null
            }, currentCookies
            @exoid.call 'users.create'
        else
          @exoid.call 'users.create')
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
