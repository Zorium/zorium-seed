# Zorium Seed

![zorium](./src/static/images/zorium_icon_256.png)


[![Sauce Test Status](https://saucelabs.com/browser-matrix/Zolmeister.svg)](https://saucelabs.com/u/Zolmeister)

#### functional tests - fast local

run local selenium server  

```bash
docker run -i --rm -p 4444:4444 selenium/standalone-chrome:2.45.0
```

run dev server

```bash
npm run dev
```

(HOSTNAME is your local ip address)  

```bash
HOSTNAME=192.168.1.1 npm run watch-functional
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
HOSTNAME=192.168.1.1 npm run test-functional
```
