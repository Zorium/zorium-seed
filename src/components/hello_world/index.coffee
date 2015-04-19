z = require 'zorium'
Button = require 'zorium-paper/button'
paperColors = require 'zorium-paper/colors.json'
Model = require '../../models/example'

if window?
  require './index.styl'

module.exports = class HelloWorld
  constructor: ->
    @state = z.state
      $button: new Button()
      model: Model.get()

  render: =>
    {$button, model} = @state.getValue()

    z '.z-hello-world',
      z '.content',
        'Hello World'
        z 'br'
        model?.name
        z 'br'
        z $button,
          text: 'click me'
          isRaised: true
          colors:
            c200: paperColors.$blue200
            c500: paperColors.$blue500
            c600: paperColors.$blue600
            c700: paperColors.$blue700
