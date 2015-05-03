z = require 'zorium'
paperColors = require 'zorium-paper/colors.json'
Rx = require 'rx-lite'

config = require './config'
HomePage = require './pages/home'
RedPage = require './pages/red'
FourOhFourPage = require './pages/404'

styles = if not window?
  # Avoid webpack include
  _fs = 'fs'
  fs = require _fs
  fs.readFileSync './dist/bundle.css', 'utf-8'
else
  null

class RootComponent
  constructor: ->
    @state = z.state {
      $homePage: new HomePage()
      $redPage: new RedPage()
      $fourOhFourPage: new FourOhFourPage()
    }

  render: ({path}) ->
    {$homePage, $redPage, $fourOhFourPage} = @state.getValue()

    pathToPage = (path) ->
      switch path
        when '/'
          $homePage
        when '/red'
          $redPage
        else
          $fourOhFourPage

    $pathPage = pathToPage(path)

    if $pathPage is $fourOhFourPage
      z.server.setStatus 404

    z $pathPage, {styles}

module.exports = ->
  new RootComponent()
