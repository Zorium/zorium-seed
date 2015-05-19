fs = require 'fs'
_ = require 'lodash'
del = require 'del'
gulp = require 'gulp'
karma = require('karma').server
webpack = require 'webpack'
mocha = require 'gulp-mocha'
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

paths =
  static: './src/static/**/*'
  coffee: ['./*.coffee', './src/**/*.coffee', './test/**/*.coffee']
  cover: [
    './*.coffee'
    './src/**/*.coffee'
    '!./src/**/*.test.coffee'
    '!./src/**/test.coffee'
  ]
  unitTests: ['./src/**/test.coffee', './src/**/*.test.coffee']
  serverTests: './test/server/index.coffee'
  functionalTests: './test/functional/**/*.coffee'
  root: './src/root.coffee'
  dist: './dist'
  build: './build'

karmaConf =
  singleRun: true
  frameworks: ['mocha']
  files: [paths.build + '/bundle.js']
  browsers: ['Chrome', 'Firefox']

cssLoader = 'css!autoprefixer!' +
            'stylus?paths[]=bower_components&paths[]=node_modules'
webpackConfig =
  devtool: 'inline-source-map'
  module:
    exprContextRegExp: /$^/
    exprContextCritical: false
    loaders: [
      { test: /\.coffee$/, loader: 'coffee' }
      { test: /\.json$/, loader: 'json' }
    ]
  plugins: [
    new webpack.ResolverPlugin \
      new webpack.ResolverPlugin.DirectoryDescriptionFilePlugin \
        'bower.json', ['main']
  ]
  resolve:
    root: [__dirname + '/bower_components']
    extensions: ['.coffee', '.js', '.json', '']
  output:
    filename: 'bundle.js'
    publicPath: '/'

gulp.task 'dev', ['dev:webpack-server', 'dev:server']
gulp.task 'test', ['test:lint', 'test:coverage', 'test:karma']
gulp.task 'build', ['build:scripts:prod', 'build:static:prod']

gulp.task 'watch', -> gulp.watch paths.coffee, ['test:unit']
gulp.task 'watch:phantom', -> gulp.watch paths.coffee, ['test:karma:phantom']
gulp.task 'watch:server', -> gulp.watch paths.coffee, ['test:server']
gulp.task 'watch:functional', -> gulp.watch paths.coffee, ['test:functional']

gulp.task 'test:lint', ->
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

gulp.task 'test:karma:phantom', ['build:scripts:test'], (cb) ->
  karma.start _.defaults({
    browsers: ['PhantomJS']
  }, karmaConf), cb

gulp.task 'test:server', ->
  gulp.src paths.serverTests
    .pipe mocha()

gulp.task 'test:karma', ['build:scripts:test'], (cb) ->
  karma.start karmaConf, cb

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
    './src/root'
  ]

  compiler = webpack _.defaults {
    entry: entries
    output:
      path: __dirname
      publicPath: "//#{webpackDevHostname}:#{webpackDevPort}/"
    module: _.defaults {
      postLoaders: [
        { test: /\.coffee$/, loader: 'transform/cacheable?envify' }
      ]
      loaders: webpackConfig.module.loaders.concat [
        { test: /\.styl$/, loader: 'style!' + cssLoader}
      ]
    }, webpackConfig.module
    plugins: webpackConfig.plugins.concat [
      new webpack.HotModuleReplacementPlugin()
    ]
  }, webpackConfig

  new WebpackDevServer compiler,
    publicPath: "//#{webpackDevHostname}:#{webpackDevPort}/"
    hot: true
  .listen webpackDevPort, (err) ->
    if err
      console.trace err
    console.log 'Webpack listening on port %d', webpackDevPort

gulp.task 'build:static:dev', ->
  gulp.src paths.static
    .pipe gulp.dest paths.build

gulp.task 'build:scripts:test', ->
  gulp.src paths.unitTests
  .pipe gulpWebpack _.defaults {
    module: _.defaults {
      postLoaders: [
        { test: /\.coffee$/, loader: 'transform/cacheable?envify' }
      ]
      loaders: webpackConfig.module.loaders.concat [
        { test: /\.styl$/, loader: 'style!' + cssLoader}
      ]
    }, webpackConfig.module
    plugins: webpackConfig.plugins.concat [
      new RewirePlugin()
    ]
  }, webpackConfig
  .pipe gulp.dest paths.build

gulp.task 'build:clean:dist', (cb) ->
  del paths.dist, cb

gulp.task 'build:static:prod', ['build:clean:dist'], ->
  gulp.src paths.static
    .pipe gulp.dest paths.dist

gulp.task 'build:scripts:prod', ['build:clean:dist'], ->
  gulp.src paths.root
  .pipe gulpWebpack (_.defaults {
    devtool: 'source-map'
    plugins: webpackConfig.plugins.concat [
      new webpack.optimize.UglifyJsPlugin()
      new ExtractTextPlugin 'bundle.css'
    ]
    output: _.defaults {
      filename: '[hash].bundle.js'
    }, webpackConfig.output
    module: _.defaults {
      loaders: webpackConfig.module.loaders.concat [
        {
          test: /\.styl$/
          loader: ExtractTextPlugin.extract 'style', cssLoader
        }
      ]
    }, webpackConfig.module
  }, webpackConfig)
  , null, (err, stats) ->
    if err
      console.trace err
      return
    statsJson = JSON.stringify stats.toJson()
    fs.writeFileSync "#{__dirname}/#{paths.dist}/stats.json", statsJson
  .pipe gulp.dest paths.dist
