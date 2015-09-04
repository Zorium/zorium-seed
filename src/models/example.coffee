config = require '../config'

module.exports = class Example
  constructor: ({@netox, @user}) -> null

  getCount: =>
    @user.getMe()
    .flatMapLatest ({accessToken}) =>
      @netox.stream config.API_URL + '/demo/count',
        headers:
          Authorization: "Token #{accessToken}"
      .map ({count}) -> count

  incrementCount: =>
    @user.getMe().take(1).toPromise()
    .then ({accessToken}) =>
      @netox.fetch config.API_URL + '/demo/count',
        method: 'POST'
        headers:
          Authorization: "Token #{accessToken}"
