z = require 'zorium'

Head = require '../../components/head'

module.exports = class FourOhFourPage
  constructor: ->
    @state = z.state
      $head: new Head()

  render: ({styles}) =>
    {$head} = @state.getValue()

    z 'html',
      z $head, {styles}
      z 'body',
        z '#zorium-root',
          z '.z-root',
            z 'div',
              '404 page not found'
              z 'br'
              '(╯°□°)╯︵ ┻━┻'
