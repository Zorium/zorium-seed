z = require 'zorium'


module.exports = class FourOhFourPage
  render: ->
    z 'div',
      '404 page not found'
      z 'br'
      '(╯°□°)╯︵ ┻━┻'
