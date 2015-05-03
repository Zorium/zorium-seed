z = require 'zorium'
paperColors = require 'zorium-paper/colors.json'
Rx = require 'rx-lite'
Routes = require 'routes'
Qs = require 'qs'

config = require './config'
HomePage = require './pages/home'
RedPage = require './pages/red'
FourOhFourPage = require './pages/404'
StateService = require './services/state'

styles = if not window?
  # Avoid webpack include
  _fs = 'fs'
  fs = require _fs
  fs.readFileSync './dist/bundle.css', 'utf-8'
else
  null

parseUrl = (url) ->
  if window?
    a = document.createElement 'a'
    a.href = url

    {
      pathname: a.pathname
      hash: a.hash
      search: a.search
      path: a.pathname + a.search
    }
  else
    # Avoid webpack include
    _url = 'url'
    URL = require(_url)
    parsed = URL.parse url

    {
      pathname: parsed.pathname
      hash: parsed.hash
      search: parsed.search
      path: parsed.path
    }

class RootComponent
  constructor: ->
    router = new Routes()

    $homePage = new HomePage()
    $redPage = new RedPage()
    $fourOhFourPage = new FourOhFourPage()

    router.addRoute '/', -> $homePage
    router.addRoute '/red', -> $redPage
    router.addRoute '*', -> $fourOhFourPage

    @state = z.state {
      router
      $fourOhFourPage
    }

  render: ({path}) =>
    {router, $fourOhFourPage} = @state.getValue()

    url = parseUrl path
    query = Qs.parse(url.search?.slice(1))
    route = router.match url.pathname

    $currentPage = route.fn()

    if $currentPage is $fourOhFourPage
      z.server.setStatus 404

    z $currentPage, {
      styles
      query
      params: route.params
    }

module.exports = ->
  StateService.clear()
  new RootComponent()
