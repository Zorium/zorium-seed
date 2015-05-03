z = require 'zorium'

Head = require '../../components/head'
Red = require '../../components/red'
Model = require '../../models/example'

module.exports = class HomePage
  constructor: ->
    @state = z.state
      $head: new Head()
      $red: new Red()
      model: Model.get()

  render: ({styles}) =>
    {$head, $red, model} = @state.getValue()

    z 'html',
      z $head, {styles}
      z 'body',
        z '#zorium-root',
          z 'div',
            if model
              z $red, {model}
