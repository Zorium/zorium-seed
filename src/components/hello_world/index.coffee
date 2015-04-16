z = require 'zorium'
Button = require 'zorium-paper/button'
paperColors = require 'zorium-paper/colors.json'

if window?
  require './index.styl'

module.exports = class HelloWorld
  constructor: ->
    @state = z.state
      $button: new Button()

  render: =>
    {$button} = @state.getValue()

    z '.z-hello-world',
      'Hello World'
      z $button,
        text: 'click me'
        isRaised: true
        colors:
          c200: paperColors.$blue200
          c500: paperColors.$blue500
          c600: paperColors.$blue600
          c700: paperColors.$blue700
