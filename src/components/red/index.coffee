z = require 'zorium'
Button = require 'zorium-paper/button'
Input = require 'zorium-paper/input'
paperColors = require 'zorium-paper/colors.json'

if window?
  require './index.styl'

module.exports = class Red
  constructor: ->
    @$button = new Button()
    @$input = new Input()

  goToHome: ->
    z.router.go '/'

  render: =>
    z '.z-red',
      z '.content',
        'Hello World'
        z 'br'
        z @$button,
          text: 'click me'
          isRaised: true
          colors:
            c200: paperColors.$blue200
            c500: paperColors.$blue500
            c600: paperColors.$blue600
            c700: paperColors.$blue700
          onclick: @goToHome
        z 'br'
        z @$input,
          hintText: 'abc'
          colors:
            c200: paperColors.$blue200
            c500: paperColors.$blue500
            c600: paperColors.$blue600
            c700: paperColors.$blue700
