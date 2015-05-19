z = require 'zorium'
_ = require 'lodash'

Head = require '../../components/head'

module.exports = class FourOhFourPage
  constructor: ->
    @state = z.state
      $head: new Head()

  renderHead: (params) =>
    {$head} = @state.getValue()

    z $head, _.defaults {
      title: 'Zorium Seed - 404'
    }, params

  render: ->
    z '.p-404',
      '404 page not found'
      z 'br'
      '(╯°□°)╯︵ ┻━┻'
