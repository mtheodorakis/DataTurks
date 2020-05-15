FROM node:carbon-alpine AS dataturks-fe-builder

RUN apk update && apk add python make g++
RUN npm i -g nodemon && nodemon -v

RUN mkdir /bazaar

COPY src /bazaar/src
COPY api /bazaar/api
COPY webpack /bazaar/webpack
COPY semantic /bazaar/semantic
COPY bin /bazaar/bin
COPY build /bazaar/build
COPY static /bazaar/static

COPY js /bazaar/js
COPY css /bazaar/css
COPY vendor /bazaar/vendor

COPY proxy /bazaar/proxy

COPY .babelrc /bazaar/.babelrc
COPY server.babel.js /bazaar/server.babel.js

COPY semantic.json /bazaar/semantic.json
COPY package.json /bazaar/package.json
COPY onprem.php /bazaar/onprem.php

WORKDIR /bazaar
RUN mkdir uploads && \
  npm install && \
  npm run build-onprem && \
  npm prune

RUN rm -rf src/components && \
rm -rf src/containers && \
rm -rf src/theme && \
rm -rf src/utils


FROM node:carbon-alpine

COPY --from=dataturks-fe-builder /bazaar /bazaar
WORKDIR /bazaar

RUN apk update && apk add apache2 apache2-proxy php7-apache2 && rm -rf /var/cache/apk/*

COPY proxy/onprem-dataturks.com.conf /etc/apache2/conf.d/



EXPOSE 3000
EXPOSE 3030
EXPOSE 80

#CMD npm run start-onprem
CMD bin/run.sh
