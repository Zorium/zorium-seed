z = require 'zorium'
Button = require 'zorium-paper/button'
Input = require 'zorium-paper/input'

if window?
  require './index.styl'

module.exports = class Red
  constructor: ->
    @$button = new Button({
      $children: 'click me'
      isRaised: true
      color: 'blue'
      onclick: @goToHome
    })
    @$input = new Input({
      label: 'abc'
      color: 'blue'
    })

  goToHome: ->
    z.router.go '/'

  render: =>
    z '.z-red',
      z '.content',
        'Hello World'
        z 'br'
        z '.t-click-me',
          @$button
        @$input
