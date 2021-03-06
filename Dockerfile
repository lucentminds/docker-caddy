#
# Builder
#
FROM lucentminds/caddy:builder as builder

ARG version="0.10.12"
ARG plugins="git"

# process wrapper
RUN go get -v github.com/abiosoft/parent

RUN VERSION=${version} PLUGINS=${plugins} /bin/sh /usr/bin/builder.sh

#
# Final stage
#
FROM alpine:3.7
LABEL maintainer "Scott Johnson <scott@lucentminds.com>"

ARG version="0.10.12"
LABEL caddy_version="$version"

# Let's Encrypt Agreement
ENV ACME_AGREE="false"

RUN apk add --no-cache openssh-client git

# install caddy
COPY --from=builder /install/caddy /usr/bin/caddy

# validate install
RUN /usr/bin/caddy -version
RUN /usr/bin/caddy -plugins

EXPOSE 80 443 2015
VOLUME /root/.caddy /srv
WORKDIR /srv

# COPY Caddyfile /etc/Caddyfile
COPY Caddyfile /root/.caddy/Caddyfile
COPY index.html /srv/index.html

# install process wrapper
COPY --from=builder /go/bin/parent /bin/parent

ENTRYPOINT ["/bin/parent", "caddy"]
CMD ["--conf", "/root/.caddy/Caddyfile", "--log", "stdout", "--agree=$ACME_AGREE"]

