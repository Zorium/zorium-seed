fs = require 'fs'
_ = require 'lodash'
del = require 'del'
path = require 'path'
gulp = require 'gulp'
karma = require('karma').server
webpack = require 'webpack'
mocha = require 'gulp-mocha'
Promise = require 'bluebird'
log = require 'clay-loglevel'
rename = require 'gulp-rename'
nodemon = require 'gulp-nodemon'
gulpWebpack = require 'gulp-webpack'
coffeelint = require 'gulp-coffeelint'
RewirePlugin = require 'rewire-webpack'
istanbul = require 'gulp-coffee-istanbul'
WebpackDevServer = require 'webpack-dev-server'
clayLintConfig = require 'clay-coffeescript-style-guide'
ExtractTextPlugin = require 'extract-text-webpack-plugin'

config = require './src/config'

FUNCTIONAL_TEST_TIMEOUT_MS = 10 * 1000 # 10sec

karmaConf =
  frameworks: ['mocha']
  client:
    useIframe: true
    captureConsole: true
    mocha:
      timeout: 1000
  files: ['build/test/bundle.js']
  browsers: ['Chrome', 'Firefox']

webpackConfig =
  devtool: 'source-map'
  module:
    exprContextRegExp: /$^/
    exprContextCritical: false
    loaders: [
      { test: /\.coffee$/, loader: 'coffee' }
      { test: /\.json$/, loader: 'json' }
      {
        test: /\.styl$/
        loader: 'style!css!autoprefixer!' +
          'stylus?paths[]=bower_components&paths[]=node_modules'
      }
    ]
  plugins: [
    new webpack.ResolverPlugin(
      new webpack.ResolverPlugin.DirectoryDescriptionFilePlugin(
        'bower.json', ['main']
      )
    )
  ]
  resolve:
    root: [path.join(__dirname, 'bower_components')]
    extensions: ['.coffee', '.js', '.json', '']
  output:
    filename: 'bundle.js'
    publicPath: '/'


paths =
  static: './src/static/**/*'
  coffee: [
    './*.coffee'
    './src/**/*.coffee'
    './test/**/*.coffee'
  ]
  cover: [
    './*.coffee'
    './src/**/*.coffee'
    '!./src/**/*.test.coffee'
    '!./src/**/test.coffee'
  ]
  tests: ['./src/**/test.coffee', './src/**/*.test.coffee']
  serverTests: './test/server/index.coffee'
  functionalTests: './test/functional/**/*.coffee'
  root: './src/root.coffee'
  rootTests: './test/index.coffee'
  dist: './dist'
  build: './build'

mochaKiller = do ->
  pendingCnt = 0

  check = ->
    setTimeout ->
      if pendingCnt is 0
        process.exit() # mocha hangs
    , 100

  ->
    pendingCnt += 1

    hasBeenCalled = false
    ->
      unless hasBeenCalled
        hasBeenCalled = true
        pendingCnt -= 1
        check()

gulp.task 'build', ['scripts:prod', 'static:prod']

# start the dev server, and auto-update
gulp.task 'dev', ['server:webpack', 'server:dev:watch']

gulp.task 'test', ['test:karma', 'test:node:coverage', 'lint']

gulp.task 'watch', ->
  gulp.watch paths.coffee, ['test:unit']

gulp.task 'watch:phantom', ->
  gulp.watch paths.coffee, ['test:unit:phantom']

gulp.task 'watch:server', ->
  gulp.watch paths.coffee, ['test:server:watch']

gulp.task 'watch:functional', ->
  gulp.watch paths.coffee, ['test:functional:watch']

gulp.task 'lint', ->
  gulp.src paths.coffee
    .pipe coffeelint(null, clayLintConfig)
    .pipe coffeelint.reporter()

gulp.task 'test:karma', ['scripts:test'], ->
  karma.start _.defaults(singleRun: true, karmaConf), mochaKiller()

gulp.task 'server:webpack', ->
  webpackDevPort = config.WEBPACK_DEV_PORT
  webpackDevHostname = config.WEBPACK_DEV_HOSTNAME
  isMockingApi = config.MOCK

  entries = [
    "webpack-dev-server/client?http://#{webpackDevHostname}:#{webpackDevPort}"
    'webpack/hot/dev-server'
  ]
  # Order matters because mock overrides window.XMLHttpRequest
  if isMockingApi
    entries = entries.concat ['./src/mock']
  entries = entries.concat ['./src/root']

  new WebpackDevServer webpack(_.defaults {
    entry: entries
    devtool: 'inline-source-map'
    output: _.defaults {
      path: __dirname
      publicPath: "//#{webpackDevHostname}:#{webpackDevPort}/"
    }, webpackConfig
    module: _.defaults {
      postLoaders: [
        { test: /\.coffee$/, loader: 'transform/cacheable?envify' }
      ]
    }, webpackConfig.module
    plugins: webpackConfig.plugins.concat [
      new webpack.HotModuleReplacementPlugin()
    ]
  }, webpackConfig),
    publicPath: "//#{webpackDevHostname}:#{webpackDevPort}/"
    hot: true
  .listen webpackDevPort, (err) ->
    if err
      log.trace err
    log.info 'Webpack listening on port %d', webpackDevPort

gulp.task 'server:dev:watch', ['static:dev'], ->
  nodemon {script: 'bin/dev_server.coffee', ext: 'js json coffee'}

gulp.task 'server:dev', ['static:dev'], ->
  require('./bin/dev_server.coffee')

gulp.task 'test:server:watch', ->
  gulp.src paths.serverTests
    .pipe mocha()

gulp.task 'test:functional', ->
  end = mochaKiller()
  gulp.src paths.functionalTests
    .pipe mocha(timeout: FUNCTIONAL_TEST_TIMEOUT_MS)
    .on 'error', end
    .once 'end', end

gulp.task 'test:node:coverage', ->
  end = mochaKiller()
  gulp.src paths.cover
    .pipe istanbul includeUntested: false
    .pipe istanbul.hookRequire()
    .on 'finish', ->
      gulp.src paths.tests.concat [paths.serverTests]
        .pipe mocha()
        .pipe istanbul.writeReports()
        .on 'error', end
        .once 'end', end

gulp.task 'test:functional:watch', ->
  gulp.src paths.functionalTests
    .pipe mocha(timeout: FUNCTIONAL_TEST_TIMEOUT_MS)

gulp.task 'test:unit', ->
  gulp.src paths.tests
    .pipe mocha()

gulp.task 'test:unit:phantom', ['scripts:test'], (cb) ->
  karma.start _.defaults({
    singleRun: true,
    browsers: ['PhantomJS']
  }, karmaConf), cb

gulp.task 'static:dev', ->
  gulp.src paths.static
    .pipe gulp.dest paths.build

gulp.task 'scripts:test', ->
  gulp.src paths.tests
  .pipe gulpWebpack _.defaults {
    devtool: 'inline-source-map'
    module: _.defaults {
      postLoaders: [
        { test: /\.coffee$/, loader: 'transform/cacheable?envify' }
      ]
    }, webpackConfig.module
    plugins: webpackConfig.plugins.concat [
      new RewirePlugin()
    ]
  }, webpackConfig
  .pipe gulp.dest paths.build + '/test/'


#
# Production compilation
#

gulp.task 'clean:dist', (cb) ->
  del paths.dist, cb

gulp.task 'static:prod', ['clean:dist'], ->
  gulp.src paths.static
    .pipe gulp.dest paths.dist

gulp.task 'scripts:prod', ['clean:dist'], ->
  gulp.src paths.root
  .pipe gulpWebpack (_.defaults {
    plugins: webpackConfig.plugins.concat [
      new webpack.optimize.UglifyJsPlugin()
      new ExtractTextPlugin 'bundle.css'
    ]
    output: _.defaults {
      filename: '[hash].bundle.js'
    }, webpackConfig.output
    module: _.defaults {
      loaders: _.map webpackConfig.module.loaders, (load) ->
        if _.includes load.loader, 'stylus'
          _.defaults {
            loader: ExtractTextPlugin.extract \
              load.loader.split('!')[0] + '-loader',
              load.loader.slice(load.loader.indexOf('!'), load.loader.length)
          }, load
        else
          load
    }, webpackConfig.module
  }, webpackConfig)
  , null, (err, stats) ->
    if err
      return
    statsJson = JSON.stringify stats.toJson()
    fs.writeFileSync "#{__dirname}/#{paths.dist}/stats.json", statsJson
  .pipe gulp.dest paths.dist
