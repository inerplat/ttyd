#!/bin/bash

runuser -l kube -c "KUBERNETES_PORT_443_TCP=$KUBERNETES_PORT_443_TCP KUBERNETES_PORT_443_TCP_PROTO=$KUBERNETES_PORT_443_TCP_PROTO KUBERNETES_PORT_443_TCP_ADDR=$KUBERNETES_PORT_443_TCP_ADDR KUBERNETES_PORT_443_TCP_PORT=$KUBERNETES_PORT_443_TCP_PORT KUBERNETES_SERVICE_HOST=$KUBERNETES_SERVICE_HOST KUBERNETES_PORT=$KUBERNETES_PORT KUBERNETES_SERVICE_PORT=$KUBERNETES_SERVICE_PORT KUBERNETES_SERVICE_PORT_HTTPS=$KUBERNETES_SERVICE_PORT_HTTPS ttyd -t enableZmodem=true -W bash > /dev/null 2>&1 &"
disown -a
exit 0
