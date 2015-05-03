z = require 'zorium'

Head = require '../../components/head'
Red = require '../../components/red'

module.exports = class HomePage
  constructor: ->
    @state = z.state
      $head: new Head()
      $red: new Red()

  render: ({styles}) =>
    {$head, $red} = @state.getValue()

    z 'html',
      z $head, {styles}
      z 'body',
        z '#zorium-root',
          z 'div',
            z $red
