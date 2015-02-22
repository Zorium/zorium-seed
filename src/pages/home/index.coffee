z = require 'zorium'
_ = require 'lodash'

HelloWorld = require '../../components/hello_world'

module.exports = class HomePage
  constructor: ->
    @state = z.state
      $hello: new HelloWorld()

  render: =>
    {$hello} = @state()

    z 'div',
      z $hello
