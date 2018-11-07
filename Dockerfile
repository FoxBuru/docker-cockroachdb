FROM alpine:latest
ARG TZ

RUN wget --quiet https://binaries.cockroachdb.com/cockroach-v2.1.0.linux-musl-amd64.tgz -O /tmp/cockroach.tgz && \
    tar xvzf /tmp/cockroach.tgz --strip 1 && apk update && apk add tzdata && apk add upx && apk add ca-certificates && \
    upx -9 /cockroach && cp /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone && \
    update-ca-certificates

FROM scratch

ENV COCKROACH_CHANNEL=official-docker

COPY --from=0 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=0 /cockroach /cockroach/cockroach
COPY --from=0 /etc/timezone /etc/timezone
COPY --from=0 /etc/localtime /etc/localtime

EXPOSE 26257 8080

ENTRYPOINT ["/cockroach/cockroach"]
