config = require '../config'

module.exports = class User
  constructor: ({@auth}) -> null

  getMe: =>
    @auth.stream config.API_URL + '/demo/users/me'
