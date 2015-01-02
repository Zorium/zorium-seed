express = require 'express'
dust = require 'dustjs-linkedin'
fs = require 'fs'
_ = require 'lodash'
Promise = require 'bluebird'
compress = require 'compression'
log = require 'clay-loglevel'

config = require './src/config'

app = express()
router = express.Router()

log.enableAll()

# Dust templates
# Don't compact whitespace, because it breaks the javascript partial
dust.optimizers.format = (ctx, node) -> node

indexTpl = dust.compile fs.readFileSync('index.dust', 'utf-8'), 'index'


distJs = if config.ENV is config.ENVS.PROD \
          then fs.readFileSync('dist/js/bundle.js', 'utf-8')
          else null
distCss = if config.ENV is config.ENVS.PROD \
          then fs.readFileSync('dist/css/bundle.css', 'utf-8')
          else null

dust.loadSource indexTpl

app.use compress()

if config.ENV is config.ENVS.PROD
then app.use express['static'](__dirname + '/dist')
else app.use express['static'](__dirname + '/build')

# After checking static files
app.use router

# Routes
router.get '*', (req, res) ->
  renderHomePage()
  .then (html) ->
    res.send html
  .catch (err) ->
    log.trace err
    res.status(500).send()

# Cache rendering
renderHomePage = do ->
  page =
    inlineSource: config.ENV is config.ENVS.PROD
    webpackDevHostname: config.WEBPACK_DEV_HOSTNAME
    title: 'Zorium Seed'
    description: 'Zorium - (╯°□°）╯︵ ┻━┻)'
    keywords: 'Zorium'
    name: 'Zorium'
    twitterHandle: '@ZoriumJS'
    themeColor: '#00695C'
    favicon: '/images/zorium_icon_32.png'
    icon1024: '/images/zorium_icon_1024.png'
    icon256: '/images/zorium_icon_256.png'
    url: 'http://zorium.org'
    distjs: distJs
    distcss: distCss

  rendered = Promise.promisify(dust.render, dust) 'index', page

  -> rendered

module.exports = app
