z = require 'zorium'

HelloWorld = require '../../components/hello_world'

module.exports = class HomePage
  constructor: ->
    @state = z.state
      $hello: new HelloWorld()

  render: =>
    {$hello} = @state.getValue()

    z 'div',
      z $hello
