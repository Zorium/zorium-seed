_ = require 'lodash'
z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
Red = require '../../components/red'

module.exports = class RedPage
  constructor: ({model, router}) ->
    @$head = new Head({model})
    @$red = new Red({router})

  renderHead: (params) =>
    z @$head, _.defaults {
      title: 'Zorium Seed - Red Page'
    }, params

  render: =>
    z '.p-red',
      @$red
