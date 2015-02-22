z = require 'zorium'

styles = require './index.styl'

module.exports = class HelloWorld
  constructor: ->
    styles.use()

  render: ->
    z '.z-hello-world', 'Hello World'
