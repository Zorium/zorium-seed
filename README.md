# Zorium Seed
[![zorium](./src/static/images/zorium_icon_256.png)](https://zorium.org)


[![Sauce Test Status](https://saucelabs.com/browser-matrix/Zolmeister.svg)](https://saucelabs.com/u/Zolmeister)

This project provides the base [Zorium](https://zorium.org) setup, following all current best practices.  

## Dev

Run live-updating webpack dev-server

  - `npm run demo-api`
  - `npm run dev`
    - `http://127.0.0.1:3000`


## Production
Environment variable are dynamically injected at runtime (for running in Docker)

  - `npm run dist`
  - `npm start`

```bash
npm run dist
docker build -t zorium-seed .

docker run \
    --restart always \
    -p 3000:3000 \
    -e PORT=3000 \
    --name zorium-seed \
    -d \
    -t zorium-seed
```

## Testing

  - `npm test`
    - server/client unit tests
  - `npm run watch`
    - auto-run unit tests
