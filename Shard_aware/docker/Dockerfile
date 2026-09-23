# ICSOC 2026 Artifact – Tendermint + FluxChain + Shard-Aware Routing
FROM golang:1.22-alpine AS builder
WORKDIR /src
COPY protocol/ ./protocol/
RUN cd protocol && go mod tidy && CGO_ENABLED=0 go build -o /shard-router ./...

FROM tendermint/tendermint:v0.37.0
USER root
RUN apk add --no-cache python3 py3-pip bash curl
COPY --from=builder /shard-router /usr/local/bin/
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 26656 26657 26660
ENTRYPOINT ["/entrypoint.sh"]
