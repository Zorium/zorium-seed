z = require 'zorium'

Head = require '../../components/head'

module.exports = class FourOhFourPage
  constructor: ->
    @state = z.state
      $head: new Head()

  renderHead: ({styles}) =>
    {$head} = @state.getValue()

    z $head, {styles}

  render: ->
    z 'div',
      z 'div',
        '404 page not found'
        z 'br'
        '(╯°□°)╯︵ ┻━┻'
