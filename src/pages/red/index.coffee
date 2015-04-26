z = require 'zorium'

Red = require '../../components/red'

module.exports = class HomePage
  constructor: ->
    @state = z.state
      $red: new Red()

  render: =>
    {$red} = @state.getValue()

    z 'div',
      z $red
