z = require 'zorium'

Head = require '../../components/head'
HelloWorld = require '../../components/hello_world'
Model = require '../../models/example'

module.exports = class HomePage
  constructor: ->
    @state = z.state
      $head: new Head()
      $hello: new HelloWorld()
      model: Model.get()

  render: ({styles}) =>
    {$head, $hello, model} = @state.getValue()

    z 'html',
      z $head, {styles}
      z 'body',
        z '#zorium-root',
          z 'div',
            if model
              z $hello, {model}
