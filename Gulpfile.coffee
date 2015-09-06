fs = require 'fs'
_ = require 'lodash'
del = require 'del'
gulp = require 'gulp'
karma = require('karma').server
webpack = require 'webpack'
mocha = require 'gulp-mocha'
nodemon = require 'gulp-nodemon'
manifest = require 'gulp-manifest'
gulpWebpack = require 'gulp-webpack'
coffeelint = require 'gulp-coffeelint'
RewirePlugin = require 'rewire-webpack'
istanbul = require 'gulp-coffee-istanbul'
WebpackDevServer = require 'webpack-dev-server'
clayLintConfig = require 'clay-coffeescript-style-guide'
ExtractTextPlugin = require 'extract-text-webpack-plugin'

config = require './src/config'
paths = require './gulp_paths'

FUNCTIONAL_TEST_TIMEOUT_MS = 10 * 1000 # 10sec

karmaConfig =
  singleRun: true
  frameworks: ['mocha']
  files: [paths.build + '/bundle.js']
  browsers: ['Chrome', 'Firefox']

cssLoader = 'css!autoprefixer!stylus?paths[]=node_modules'

webpackBase =
  module:
    exprContextRegExp: /$^/
    exprContextCritical: false
  resolve:
    extensions: ['.coffee', '.js', '.json', '']
  output:
    filename: 'bundle.js'
    publicPath: '/'

gulp.task 'dev', ['dev:webpack-server', 'dev:server']
gulp.task 'test', ['lint', 'test:coverage', 'test:browser']
gulp.task 'dist', ['dist:scripts', 'dist:static', 'dist:manifest']

gulp.task 'watch', ->
  gulp.watch paths.coffee, ['test:unit']
gulp.task 'watch:phantom', ->
  gulp.watch paths.coffee, ['test:browser:phantom']
gulp.task 'watch:server', ->
  gulp.watch paths.coffee, ['test:server']
gulp.task 'watch:functional', ->
  gulp.watch paths.coffee, ['test:functional']

gulp.task 'lint', ->
  gulp.src paths.coffee
    .pipe coffeelint(null, clayLintConfig)
    .pipe coffeelint.reporter()

gulp.task 'test:coverage', ->
  gulp.src paths.cover
    .pipe istanbul includeUntested: false
    .pipe istanbul.hookRequire()
    .on 'finish', ->
      gulp.src paths.unitTests.concat [paths.serverTests]
        .pipe mocha()
        .pipe istanbul.writeReports({
          reporters: ['html', 'text', 'text-summary']
        })

gulp.task 'test:unit', ->
  gulp.src paths.unitTests
    .pipe mocha()

gulp.task 'test:browser:phantom', ['build:scripts:test'], (cb) ->
  karma.start _.defaults({
    browsers: ['PhantomJS']
  }, karmaConfig), cb

gulp.task 'test:server', ->
  gulp.src paths.serverTests
    .pipe mocha()

gulp.task 'test:browser', ['build:scripts:test'], (cb) ->
  karma.start karmaConfig, cb

gulp.task 'test:functional', ->
  gulp.src paths.functionalTests
    .pipe mocha(timeout: FUNCTIONAL_TEST_TIMEOUT_MS)

gulp.task 'dev:server', ['build:static:dev'], ->
  nodemon {script: 'bin/dev_server.coffee', ext: 'js json coffee'}

gulp.task 'dev:webpack-server', ->
  webpackDevPort = config.WEBPACK_DEV_PORT
  webpackDevHostname = config.WEBPACK_DEV_HOSTNAME

  entries = [
    "webpack-dev-server/client?http://#{webpackDevHostname}:#{webpackDevPort}"
    'webpack/hot/dev-server'
    paths.root
  ]

  compiler = webpack _.defaultsDeep {
    devtool: 'inline-source-map'
    entry: entries
    output:
      path: __dirname
      publicPath: "//#{webpackDevHostname}:#{webpackDevPort}/"
    module:
      postLoaders: [
        {test: /\.coffee$/, loader: 'transform/cacheable?envify'}
      ]
      loaders: [
        {test: /\.coffee$/, loader: 'coffee'}
        {test: /\.json$/, loader: 'json'}
        {test: /\.styl$/, loader: 'style!' + cssLoader}
      ]
    plugins: [
      new webpack.HotModuleReplacementPlugin()
    ]
  }, webpackBase

  new WebpackDevServer compiler,
    publicPath: "//#{webpackDevHostname}:#{webpackDevPort}/"
    hot: true
    noInfo: true
  .listen webpackDevPort, (err) ->
    if err
      console.trace err
    console.log 'Webpack listening on port %d', webpackDevPort

gulp.task 'build:static:dev', ->
  gulp.src paths.static
    .pipe gulp.dest paths.build

gulp.task 'build:scripts:test', ->
  gulp.src paths.unitTests
  .pipe gulpWebpack _.defaultsDeep {
    devtool: 'inline-source-map'
    module:
      postLoaders: [
        {test: /\.coffee$/, loader: 'transform/cacheable?envify'}
      ]
      loaders: [
        {test: /\.coffee$/, loader: 'coffee'}
        {test: /\.json$/, loader: 'json'}
        {test: /\.styl$/, loader: 'style!' + cssLoader}
      ]
    plugins: [
      new RewirePlugin()
    ]
  }, webpackBase
  .pipe gulp.dest paths.build

gulp.task 'dist:clean', (cb) ->
  del paths.dist, cb

gulp.task 'dist:static', ['dist:clean'], ->
  gulp.src paths.static
    .pipe gulp.dest paths.dist

gulp.task 'dist:scripts', ['dist:clean'], ->
  scriptsConfig = _.defaultsDeep {
    devtool: 'source-map'
    plugins: [
      new webpack.optimize.UglifyJsPlugin()
      new ExtractTextPlugin 'bundle.css'
    ]
    output:
      filename: '[hash].bundle.js'
    module:
      loaders: [
        {test: /\.coffee$/, loader: 'coffee'}
        {test: /\.json$/, loader: 'json'}
        {
          test: /\.styl$/
          loader: ExtractTextPlugin.extract 'style', cssLoader
        }
      ]
  }, webpackBase

  gulp.src paths.root
  .pipe gulpWebpack scriptsConfig, null, (err, stats) ->
    if err
      console.trace err
      return
    statsJson = JSON.stringify {hash: stats.toJson().hash}
    fs.writeFileSync "#{__dirname}/#{paths.dist}/stats.json", statsJson
  .pipe gulp.dest paths.dist

gulp.task 'dist:manifest', ['dist:static', 'dist:scripts'], ->
  gulp.src paths.manifest
    .pipe manifest {
      hash: true
      timestamp: false
      preferOnline: true
    }
    .pipe gulp.dest paths.dist
