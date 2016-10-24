_ = require 'lodash'
z = require 'zorium'
Button = require 'zorium-paper/button'
Input = require 'zorium-paper/input'

if window?
  require './index.styl'

module.exports = class Red
  constructor: ({router}) ->
    @$button = new Button({
      isRaised: true
      color: 'blue'
      onclick: _.partial @goToHome, router
    })
    @$input = new Input({
      label: 'abc'
      color: 'blue'
    })

  goToHome: (router) ->
    router.go '/'

  render: =>
    z '.z-red',
      z '.content',
        'Hello World'
        z 'br'
        z '.t-click-me',
          z @$button,
            $children: 'click me'
        @$input
