_ = require 'lodash'
z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
Red = require '../../components/red'

module.exports = class RedPage
  constructor: ->

    @state = z.state
      $head: new Head()
      $red: new Red()

  renderHead: (params) =>
    {$head} = @state.getValue()

    z $head, _.defaults {
      title: 'Zorium Seed - Red Page'
    }, params

  render: =>
    {$red} = @state.getValue()

    z '.p-red',
      $red
