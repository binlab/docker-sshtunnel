FROM alpine:3.8

LABEL maintainer="Mark <mark.binlab@gmail.com>"

RUN addgroup -S autossh \
    && adduser -S -D -H -s /bin/false -g "AutoSSH Service" -G autossh autossh \
    && set -x \
    && apk add --no-cache autossh

USER autossh

ENTRYPOINT ["/usr/bin/autossh", \
    "-M", "0", "-T", "-N", "-g", "-v", \
    "-oStrictHostKeyChecking=no", \
    "-oServerAliveInterval=180", \
    "-oUserKnownHostsFile=/dev/null", \
    "-oGlobalKnownHostsFile=/dev/null", \
    "-i/sshtunnel_rsa"]
