z = require 'zorium'
paperColors = require 'zorium-paper/colors.json'
Rx = require 'rx-lite'
Routes = require 'routes'
Qs = require 'qs'

config = require './config'
HomePage = require './pages/home'
RedPage = require './pages/red'
FourOhFourPage = require './pages/404'

ANIMATION_TIME_MS = 500

# FIXME: depends on gulpfile
styles = if not window?
  # Avoid webpack include
  _fs = 'fs'
  fs = require _fs
  fs.readFileSync './dist/bundle.css', 'utf-8'
else
  null

# FIXME: depends on gulpfile
bundlePath = if not window?
  # Avoid webpack include
  _fs = 'fs'
  fs = require _fs
  try
    stats = JSON.parse fs.readFileSync './dist/stats.json', 'utf-8'
    "/#{stats.hash}.bundle.js"
  catch
    null
else
  null

module.exports = class App
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
      $previousTree: null
      $currentPage: null
      isEntering: false
      isActive: false
      $fourOhFourPage
    }

  render: ({req, res}) =>
    {router, $fourOhFourPage, $currentPage, $previousTree, isEntering,
     isActive} = @state.getValue()
    {path, query} = req

    route = router.match path

    $nextPage = route.fn()

    renderPage = ($page) ->
      z $page, {query, params: route.params}

    if $nextPage isnt $currentPage
      $previousTree = if $currentPage then renderPage $currentPage else null
      $currentPage = $nextPage
      @state.set {
        $currentPage
        $previousTree
        isEntering: if $previousTree then true else false
      }

      if $previousTree and window?
        window.requestAnimationFrame =>
          @state.set
            isActive: true

        setTimeout =>
          @state.set
            $previousTree: null
            isEntering: false
            isActive: false
        , ANIMATION_TIME_MS

    # FIXME
    if $currentPage is $fourOhFourPage and not window?
      res.status 404

    z 'html',
      $currentPage.renderHead {styles, bundlePath}
      z 'body',
        z '#zorium-root',
          z '.z-root',
            className: z.classKebab {isEntering, isActive}
            z '.previous',
              $previousTree
            z '.current',
              renderPage $currentPage
