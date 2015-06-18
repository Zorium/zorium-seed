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
      $currentPage: null
      $nextPage: null
      isEntering: false
      isActive: false
    }

    # FIXME: should not need subscribe
    requests.subscribe ({req, res}) =>
      {$currentPage} = @state.getValue()

      route = router.match req.path
      $page = route.fn()

      if $page instanceof FourOhFourPage
        res.status? 404

      isEntering = Boolean $currentPage

      if isEntering and window?
        @state.set {
          isEntering
          $nextPage: $page
        }

        window.requestAnimationFrame =>
          setTimeout =>
            @state.set
              isActive: true

        setTimeout =>
          @state.set
            $currentPage: $page
            $nextPage: null
            isEntering: false
            isActive: false
        , ANIMATION_TIME_MS
      else
        @state.set
          $currentPage: $page

  render: =>
    {$nextPage, $currentPage, isEntering, isActive} = @state.getValue()

    z 'html',
      $currentPage.renderHead {styles, bundlePath}
      z 'body',
        z '#zorium-root',
          z '.z-root',
            className: z.classKebab {isEntering, isActive}
            z '.current',
              $currentPage
            z '.next',
              $nextPage
