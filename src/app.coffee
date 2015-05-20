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
  constructor: ({requests}) ->
    router = new Routes()

    $homePage = new HomePage()
    $redPage = new RedPage()
    $fourOhFourPage = new FourOhFourPage()

    router.addRoute '/', -> $homePage
    router.addRoute '/red', -> $redPage
    router.addRoute '*', -> $fourOhFourPage

    @state = z.state {
      requests: requests
      $previousTree: null
      $currentPage: null
      isEntering: false
      isActive: false
    }

    # FIXME: should not need subscribe
    requests.subscribe ({req, res}) =>
      {$currentTree} = @state.getValue()

      route = router.match req.path
      $page = route.fn()

      if $page instanceof FourOhFourPage
        res.status? 404

      $previousTree = $currentTree
      $currentTree = z $page, {query: req.query, params: route.params}
      isEntering = Boolean $previousTree
      @state.set {
        $previousTree
        $currentTree
        isEntering
        $currentPage: $page
      }

      if isEntering and window?
        window.requestAnimationFrame =>
          setTimeout =>
            @state.set
              isActive: true

        setTimeout =>
          @state.set
            $previousTree: null
            isEntering: false
            isActive: false
        , ANIMATION_TIME_MS

  render: =>
    {$currentPage, $currentTree, $previousTree, isEntering, isActive} =
      @state.getValue()

    z 'html',
      $currentPage.renderHead {styles, bundlePath}
      z 'body',
        z '#zorium-root',
          z '.z-root',
            className: z.classKebab {isEntering, isActive}
            z '.previous',
              $previousTree
            z '.current',
              $currentTree
