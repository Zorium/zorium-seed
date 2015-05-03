z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
Red = require '../../components/red'
Model = require '../../models/example'

module.exports = class RedPage
  constructor: ->

    @state = z.state
      $head: new Head()
      $red: new Red()
      model: Model.get()

  renderHead: ({styles}) =>
    {$head} = @state.getValue()

    z $head, {styles, title: 'Zorium Seed - Red Page'}

  render: =>
    {$red, model} = @state.getValue()

    z '.p-red',
      if model
        z $red, {model}
