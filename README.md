# Zorium Seed

[![zorium](./src/static/images/zorium_icon_256.png)](https://zorium.org)


[![Sauce Test Status](https://saucelabs.com/browser-matrix/Zolmeister.svg)](https://saucelabs.com/u/Zolmeister)

This project provides the base [Zorium](https://zorium.org) setup, following all current best practices.  

## Dev

Run live-updating webpack dev-server

  - `npm run dev`
    - `http://localhost:3000`


## Production

Compile and minify files locally, then use Docker to start the server  
Environment variable are dynamically injected at runtime

  - `npm run dist`
  - `npm start`

```bash
npm run build
docker build -t zorium-seed .

docker run \
    --restart on-failure \
    -v /var/log:/var/log \
    -p 3000:3000 \
    -e PORT=3000 \
    -e LOG_DIR=/var/log \
    -e LOG_NAME=zorium_seed \
    --name zorium-site \
    -d \
    -t zorium-site
```

## Testing

  - `npm test`
    - real-browser karma tests
    - server/client unit tests
    - code coverage
  - `npm run test-functional`
    - see functional tests (multi-browser) below
  - `npm run watch`
    - auto-run client unit tests
  - `npm run watch-phantom`
    - auto-run karma tests
  - `npm run watch-server`
    - auto-run server tests
  - `npm run watch-functional`
    - see functional tests (fast local) below

#### functional tests - fast local

run local selenium server  

```bash
docker run -i --rm -p 4444:4444 selenium/standalone-chrome:2.45.0
```

run dev server

```bash
npm run dev
```

(HOST is your local ip address)  

```bash
HOST=192.168.1.1 npm run watch-functional
```

#### functional tests - full multi-browser

Download and run [SauceConnect](https://docs.saucelabs.com/reference/sauce-connect/)  

```bash
wget https://saucelabs.com/downloads/sc-4.3.8-linux.tar.gz && \
echo "0ae5960a9b4b33e5a8e8cad9ec4b610b68eb3520 *sc-4.3.8-linux.tar.gz" | sha1sum -c - && \
tar xvzf sc-4.3.8-linux.tar.gz
```

```bash
./sc-4.3.8-linux/bin/sc -u $SAUCE_USERNAME -k $SAUCE_ACCESS_KEY
```

run dev server

```bash
npm run dev
```

```bash
HOST=192.168.1.1 npm run test-functional
```
