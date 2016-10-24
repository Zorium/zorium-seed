z = require 'zorium'

config = require '../../config'
Head = require '../../components/head'
Red = require '../../components/red'

module.exports = class RedPage
  constructor: ({model, router, serverData}) ->
    @$head = new Head({
      model
      serverData
      meta:
        title: 'Zorium Seed - Red'
        description: 'The Red Page'
        canonical: "https://#{config.HOST}/red"
    })
    @$red = new Red({router})

  renderHead: => @$head

  render: =>
    z '.p-red',
      @$red
