module.exports = class Example
  constructor: ({@auth}) -> null

  getCount: =>
    @auth.stream('count.get').map ({count}) -> count

  incrementCount: =>
    @auth.call 'count.inc'
