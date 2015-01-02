z = require 'zorium'

styles = require './index.styl'

module.exports = class Stars
  constructor: ->
    styles.use()

    @state = z.state
      hello: 'Hello World!'

  render: =>
    z '.z-hello-world', @state().hello
