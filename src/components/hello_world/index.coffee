_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Button = require 'zorium-paper/button'
Input = require 'zorium-paper/input'

if window?
  require './index.styl'

module.exports = class HelloWorld
  constructor: ({model}) ->
    @$increment = new Button({
      $children: 'increment counter'
      isRaised: true
      color: 'amber'
      onclick: _.partial @increment, model
    })
    @$button = new Button({
      $children: 'click me'
      isRaised: true
      color: 'blue'
      onclick: @goToRed
    })
    @$input = new Input({
      label: 'abc'
      color: 'blue'
    })

    @state = z.state
      model: model
      count: model.example.getCount()
      username: model.user.getMe().map ({username}) -> username

  goToRed: ->
    z.router.go '/red'

  increment: (model) ->
    model.example.incrementCount()
    .catch log.error

  render: =>
    {model, username, count} = @state.getValue()

    z '.z-hello-world',
      z '.content',
        z '.hello',
          'Hello World'
        z '.username',
          "username: #{username}"
        z '.count',
          "count: #{count}"
        @$increment
        z '.t-click-me',
          @$button
        @$input
