z = require 'zorium'

if window?
  require './index.styl'

module.exports = class HelloWorld
  render: ->
    z '.z-hello-world', 'Hello World'
