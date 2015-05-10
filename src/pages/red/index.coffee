z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
Red = require '../../components/red'

module.exports = class RedPage
  constructor: ->

    @state = z.state
      $head: new Head()
      $red: new Red()

  renderHead: ({styles}) =>
    {$head} = @state.getValue()

    z $head, {styles, title: 'Zorium Seed - Red Page'}

  render: =>
    {$red} = @state.getValue()

    z '.p-red',
      $red
