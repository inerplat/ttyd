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


FROM nginx:1.25.3

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
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN rm -rf /etc/nginx/sites-enabled/default

COPY --from=web-builder /build/dist /usr/share/nginx/html
COPY --from=web-builder /build/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /ttyd/build/ttyd /usr/local/bin/ttyd


RUN groupadd -g 1001 readonly && \
    useradd -u 1001 -g 1001 -m -d /home/kube -s /bin/bash kube && \
    mkdir -p /home/kube/.kube && \
    chown -R kube:readonly /home/kube/.kube && \
    chmod -R 755 /home/kube/.kube

COPY bin /tmp

RUN cp /tmp/k9s-$(uname -m) /bin/k9s && \
    cp /tmp/kubectl-$(uname -m) /bin/kubectl && \
    chmod +x /bin/k9s && \
    chmod +x /bin/kubectl && \
    rm -rf /tmp/*

WORKDIR /home/kube

EXPOSE 80

COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["nginx", "-g", "daemon off;"]
