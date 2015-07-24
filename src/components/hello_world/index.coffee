z = require 'zorium'
Button = require 'zorium-paper/button'
Input = require 'zorium-paper/input'
paperColors = require 'zorium-paper/colors.json'

if window?
  require './index.styl'

module.exports = class HelloWorld
  constructor: ({model}) ->
    @$button = new Button()
    @$input = new Input()

    @state = z.state
      username: model.user.getMe().map ({username}) -> username

  goToRed: ->
    z.router.go '/red'

  render: =>
    {username} = @state.getValue()

    z '.z-hello-world',
      z '.content',
        'Hello World'
        z '.username'
          "username: #{username}"
        z 'br'
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
