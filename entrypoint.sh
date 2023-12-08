#!/bin/bash

# nginx
nginx -g "daemon off;" &
nginx_pid=$!

# ttyd
ttyd -t enableZmodem=true -W bash
