# TODO: remove, npm
COOKIE_DURATION_MS = 365 * 24 * 3600 * 1000 # 1 year

class CookieService
  getCookieOpts: ->
    path: '/'
    expires: new Date(Date.now() + COOKIE_DURATION_MS)

module.exports = new CookieService()
