FROM ubuntu:22.04 as builder

WORKDIR /ttyd

RUN apt update &&  \
    apt install -y --no-install-recommends  \
    build-essential  \
    cmake  \
    git  \
    pkg-config  \
    libwebsockets-dev  \
    libjson-c-dev  \
    libssl-dev  \
    zlib1g-dev   \
    && rm -rf /var/lib/apt/lists/*

COPY . .

RUN mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install

FROM node:20.10.0 as web-builder

WORKDIR /build

COPY html .

RUN yarn install && \
    yarn build \
    && rm -rf node_modules


FROM ubuntu:22.04

RUN apt update &&  \
    apt install -y \
    libwebsockets-dev  \
    libjson-c-dev  \
    libssl-dev  \
    zlib1g-dev   \
    openssl \
    nginx \
    vim \
    lrzsz \
    tini \
    && rm -rf /var/lib/apt/lists/*

RUN rm -rf /etc/nginx/sites-enabled/default

COPY --from=web-builder /build/dist /usr/share/nginx/html
COPY --from=web-builder /build/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /ttyd/build/ttyd /usr/local/bin/ttyd
COPY entrypoint.sh .

EXPOSE 80

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["./entrypoint.sh"]
