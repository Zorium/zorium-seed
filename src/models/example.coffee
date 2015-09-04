config = require '../config'

module.exports = class Example
  constructor: ({@auth}) -> null

  getCount: =>
    @auth.stream config.API_URL + '/demo/count'
    .map ({count}) -> count

  incrementCount: =>
    @auth.fetch config.API_URL + '/demo/count', {method: 'POST'}
