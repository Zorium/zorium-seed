z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
HelloWorld = require '../../components/hello_world'
Model = require '../../models/example'

module.exports = class HomePage
  constructor: ->
    @state = z.state
      $head: new Head()
      $hello: new HelloWorld()
      model: Model.get()

  renderHead: ({styles}) =>
    {$head} = @state.getValue()

    z $head, {styles}

  render: =>
    {$hello, model} = @state.getValue()

    z 'div',
      if model
        z $hello, {model}
