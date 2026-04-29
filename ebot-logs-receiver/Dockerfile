FROM node:22-alpine

RUN apk add --no-cache git

WORKDIR /app

RUN git clone --branch io-modernizer https://github.com/iolson/eBot-LogReceiver.git .

RUN npm ci

CMD ["node", "bin/app", "-c", "/configs/config.json"]
