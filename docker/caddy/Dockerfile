FROM node:24.18.0-alpine3.23@sha256:595398b0081eacda8e1c4c5b97b76cd1020e4d58a8ebcb4843b9bca1e79e7436 AS frontend
WORKDIR /build
COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts
COPY resources ./resources
COPY vite.config.js tsconfig.json ./
RUN npm run build

FROM golang:1.26.5-alpine3.23@sha256:622e56dbc11a8cfe87cafa2331e9a201877271cbff918af53d3be315f3da88cc AS caddy-builder
ENV CGO_ENABLED=0
RUN go install -trimpath -ldflags="-s -w" github.com/caddyserver/caddy/v2/cmd/caddy@v2.11.4

FROM caddy:2.11.4-alpine@sha256:5f5c8640aae01df9654968d946d8f1a56c497f1dd5c5cda4cf95ab7c14d58648
USER root
RUN apk upgrade --no-cache
COPY --from=caddy-builder /go/bin/caddy /usr/bin/caddy
COPY public /srv/app/public
COPY --from=frontend /build/public/build /srv/app/public/build
COPY docker/caddy/Caddyfile.local /etc/caddy/Caddyfile
USER caddy:caddy
HEALTHCHECK --interval=15s --timeout=5s --start-period=20s --retries=5 \
    CMD wget --no-check-certificate --quiet --spider https://localhost:8443/healthz || exit 1
