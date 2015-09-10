z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
HelloWorld = require '../../components/hello_world'

module.exports = class HomePage
  constructor: ({model, router}) ->
    @$head = new Head({model})
    @$hello = new HelloWorld({model, router})

  renderHead: (params) =>
    z @$head, params

  render: =>
    z '.p-home',
      @$hello
