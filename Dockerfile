# --------------------
# Build Stage
# --------------------
FROM rust:1.47-slim-buster as builder

ENV PACKAGES="curl build-essential pkg-config zlib1g-dev tzdata git \
  libpq-dev postgresql-client librust-openssl-dev"

ARG GITHUB_TOKEN=""
ARG USER_PACKAGES=""

RUN apt-get update -qq && \
  apt-get install -yq --no-install-recommends \
  $PACKAGES $USER_PACKAGES && \
  git config --global url."https://${GITHUB_TOKEN}:x-oauth-basic@github.com/".insteadOf "https://github.com/" && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  truncate -s 0 /var/log/*log

# RUN adduser -D -g '' appuser

WORKDIR /usr/src/app

COPY . .

RUN cargo build --release

# --------------------
# Final Stage
# --------------------
FROM rust:1.47-slim-buster

COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /usr/share/zoneinfo/Asia/Tokyo /usr/share/zoneinfo/Asia/Tokyo
COPY --from=builder /usr/src/app/target/release/z2p /usr/local/bin/z2p
COPY docker-entrypoint.sh /entrypoint.sh

# USER appuser

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/local/bin/z2p"]
