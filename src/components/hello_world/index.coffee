_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Button = require 'zorium-paper/button'
Input = require 'zorium-paper/input'
paperColors = require 'zorium-paper/colors.json'

if window?
  require './index.styl'

module.exports = class HelloWorld
  constructor: ({model}) ->
    @$button = new Button()
    @$increment = new Button()
    @$input = new Input()

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
        z @$increment,
          text: 'increment counter'
          isRaised: true
          colors:
            c200: paperColors.$blue200
            c500: paperColors.$blue500
            c600: paperColors.$blue600
            c700: paperColors.$blue700
          onclick: _.partial @increment, model
        z '.t-click-me',
          z @$button,
            text: 'click me'
            isRaised: true
            colors:
              c200: paperColors.$blue200
              c500: paperColors.$blue500
              c600: paperColors.$blue600
              c700: paperColors.$blue700
            onclick: @goToRed
        z 'br'
        z @$input,
          hintText: 'abc'
          colors:
            c200: paperColors.$blue200
            c500: paperColors.$blue500
            c600: paperColors.$blue600
            c700: paperColors.$blue700
