FROM bash:alpine3.19

ARG PUID=0
ARG PGID=0
# set build args as container environment variables for entrypoint reference
ENV PUID=$PUID
ENV PGID=$PGID

RUN apk update && apk add parallel aria2
COPY --chown=$PUID:$PGID . /docker
RUN chmod +x /docker/download.sh
ENTRYPOINT ["/docker/download.sh"]
