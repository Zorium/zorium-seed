z = require 'zorium'
paperColors = require 'zorium-paper/colors.json'
Rx = require 'rx-lite'
Routes = require 'routes'
Qs = require 'qs'

config = require './config'
gulpConfig = require '../gulp_config'
HomePage = require './pages/home'
RedPage = require './pages/red'
FourOhFourPage = require './pages/404'

ANIMATION_TIME_MS = 500

styles = if not window? and config.ENV is config.ENVS.PROD
  # Avoid webpack include
  _fs = 'fs'
  fs = require _fs
  fs.readFileSync gulpConfig.paths.dist + '/bundle.css', 'utf-8'
else
  null

bundlePath = if not window? and config.ENV is config.ENVS.PROD
  # Avoid webpack include
  _fs = 'fs'
  fs = require _fs
  stats = JSON.parse \
    fs.readFileSync gulpConfig.paths.dist + '/stats.json', 'utf-8'

  "/#{stats.hash}.bundle.js"
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
    }

  render: ({req, res}) =>
    {router, $currentPage, $previousTree, isEntering, isActive} =
      @state.getValue()
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

    if $currentPage instanceof FourOhFourPage
      res.status? 404

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
