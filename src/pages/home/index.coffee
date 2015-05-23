z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
HelloWorld = require '../../components/hello_world'

module.exports = class HomePage
  constructor: ->
    @$head = new Head()
    @$hello = new HelloWorld()

  renderHead: (params) =>
    z @$head, params

  render: =>
    z '.p-home',
      @$hello
