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

cfg = require './gulp_config' # gulpConfig

gulp.task 'dev', ['dev:webpack-server', 'dev:server']
gulp.task 'test', ['test:lint', 'test:coverage', 'test:karma']
gulp.task 'dist', ['dist:scripts', 'dist:static', 'dist:manifest']

gulp.task 'watch', ->
  gulp.watch cfg.paths.coffee, ['test:unit']
gulp.task 'watch:phantom', ->
  gulp.watch cfg.paths.coffee, ['test:karma:phantom']
gulp.task 'watch:server', ->
  gulp.watch cfg.paths.coffee, ['test:server']
gulp.task 'watch:functional', ->
  gulp.watch cfg.paths.coffee, ['test:functional']

gulp.task 'test:lint', ->
  gulp.src cfg.paths.coffee
    .pipe coffeelint(null, clayLintConfig)
    .pipe coffeelint.reporter()

gulp.task 'test:coverage', ->
  gulp.src cfg.paths.cover
    .pipe istanbul includeUntested: false
    .pipe istanbul.hookRequire()
    .on 'finish', ->
      gulp.src cfg.paths.unitTests.concat [cfg.paths.serverTests]
        .pipe mocha()
        .pipe istanbul.writeReports({
          reporters: ['html', 'text', 'text-summary']
        })

gulp.task 'test:unit', ->
  gulp.src cfg.paths.unitTests
    .pipe mocha()

gulp.task 'test:karma:phantom', ['build:scripts:test'], (cb) ->
  karma.start _.defaults({
    browsers: ['PhantomJS']
  }, cfg.karma), cb

gulp.task 'test:server', ->
  gulp.src cfg.paths.serverTests
    .pipe mocha()

gulp.task 'test:karma', ['build:scripts:test'], (cb) ->
  karma.start cfg.karma, cb

gulp.task 'test:functional', ->
  gulp.src cfg.paths.functionalTests
    .pipe mocha(timeout: cfg.FUNCTIONAL_TEST_TIMEOUT_MS)

gulp.task 'dev:server', ['build:static:dev'], ->
  nodemon {script: 'bin/dev_server.coffee', ext: 'js json coffee'}

gulp.task 'dev:webpack-server', ->
  webpackDevPort = cfg.WEBPACK_DEV_PORT
  webpackDevHostname = cfg.WEBPACK_DEV_HOSTNAME

  entries = [
    "webpack-dev-server/client?http://#{webpackDevHostname}:#{webpackDevPort}"
    'webpack/hot/dev-server'
    cfg.paths.root
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
        {test: /\.styl$/, loader: 'style!' + cfg.cssLoader}
      ]
    plugins: [
      new webpack.HotModuleReplacementPlugin()
    ]
  }, cfg.webpack

  new WebpackDevServer compiler,
    publicPath: "//#{webpackDevHostname}:#{webpackDevPort}/"
    hot: true
  .listen webpackDevPort, (err) ->
    if err
      console.trace err
    console.log 'Webpack listening on port %d', webpackDevPort

gulp.task 'build:static:dev', ->
  gulp.src cfg.paths.static
    .pipe gulp.dest cfg.paths.build

gulp.task 'build:scripts:test', ->
  gulp.src cfg.paths.unitTests
  .pipe gulpWebpack _.defaultsDeep {
    devtool: 'inline-source-map'
    module:
      postLoaders: [
        {test: /\.coffee$/, loader: 'transform/cacheable?envify'}
      ]
      loaders: [
        {test: /\.coffee$/, loader: 'coffee'}
        {test: /\.json$/, loader: 'json'}
        {test: /\.styl$/, loader: 'style!' + cfg.cssLoader}
      ]
    plugins: [
      new RewirePlugin()
    ]
  }, cfg.webpack
  .pipe gulp.dest cfg.paths.build

gulp.task 'dist:clean', (cb) ->
  del cfg.paths.dist, cb

gulp.task 'dist:static', ['dist:clean'], ->
  gulp.src cfg.paths.static
    .pipe gulp.dest cfg.paths.dist

gulp.task 'dist:scripts', ['dist:clean'], ->
  webpackConfig = _.defaultsDeep {
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
          loader: ExtractTextPlugin.extract 'style', cfg.cssLoader
        }
      ]
  }, cfg.webpack

  gulp.src cfg.paths.root
  .pipe gulpWebpack webpackConfig, null, (err, stats) ->
    if err
      console.trace err
      return
    statsJson = JSON.stringify {hash: stats.toJson().hash}
    fs.writeFileSync "#{__dirname}/#{cfg.paths.dist}/stats.json", statsJson
  .pipe gulp.dest cfg.paths.dist

gulp.task 'dist:manifest', ['dist:static', 'dist:scripts'], ->
  gulp.src cfg.paths.dist + '/**/*'
    .pipe manifest {
      hash: true
      timestamp: false
      preferOnline: true
    }
    .pipe gulp.dest cfg.paths.dist
