z = require 'zorium'

Head = require '../../components/head'
HelloWorld = require '../../components/hello_world'

module.exports = class HomePage
  constructor: ->
    @state = z.state
      $head: new Head()
      $hello: new HelloWorld()

  render: ({styles}) =>
    {$head, $hello} = @state.getValue()

    z 'html',
      z $head, {styles}
      z 'body',
        z '#zorium-root',
          z 'div',
            z $hello
