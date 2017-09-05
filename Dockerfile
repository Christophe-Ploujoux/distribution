FROM golang:1.8-alpine

ENV DISTRIBUTION_DIR /go/src/github.com/docker/distribution
ENV DOCKER_BUILDTAGS include_oss include_gcs

ARG GOOS=linux
ARG GOARCH=amd64

RUN set -ex \
    && apk add --no-cache make git

WORKDIR $DISTRIBUTION_DIR
COPY . $DISTRIBUTION_DIR
COPY certs /certs

RUN make PREFIX=/go clean-registry registry


FROM golang:1.8-alpine

ENV REGISTRY_STORAGE_DELETE_ENABLED true

ARG GOOS=linux
ARG GOARCH=amd64

COPY --from=0 /go/bin /go/bin
COPY cmd/registry/config.yml /etc/docker/registry/config.yml

VOLUME ["/var/lib/registry"]
EXPOSE 5000
ENTRYPOINT ["registry"]
CMD ["serve", "/etc/docker/registry/config.yml"]