class StateService
  constructor: ->
    @state = {}

  set: (key, value) =>
    @state[key] = value

  get: (key) => @state[key]

  clear: ->
    @state = {}

module.exports = new StateService()
