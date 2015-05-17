z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
HelloWorld = require '../../components/hello_world'

module.exports = class HomePage
  constructor: ->
    @state = z.state
      $head: new Head()
      $hello: new HelloWorld()

  renderHead: (params) =>
    {$head} = @state.getValue()

    z $head, params

  render: =>
    {$hello} = @state.getValue()

    z '.p-home',
      $hello
