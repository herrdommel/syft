FROM alpine:3.20

ARG SYFT_VERSION=1.42.2
ARG TARGETARCH=amd64

RUN set -eux; \
    apk add --no-cache curl ca-certificates tar; \
    update-ca-certificates; \
    case "${TARGETARCH}" in \
      amd64) SYFT_ARCH="amd64" ;; \
      arm64) SYFT_ARCH="arm64" ;; \
      *) echo "Unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    base_url="https://github.com/anchore/syft/releases/download/v${SYFT_VERSION}"; \
    archive="syft_${SYFT_VERSION}_linux_${SYFT_ARCH}.tar.gz"; \
    curl -fsSLo "/tmp/${archive}" "${base_url}/${archive}"; \
    curl -fsSLo /tmp/checksums.txt "${base_url}/syft_${SYFT_VERSION}_checksums.txt"; \
    cd /tmp; \
    grep "  ${archive}\$" checksums.txt | sha256sum -c -; \
    mkdir -p /tmp/syft /licenses/syft; \
    tar -xzf "/tmp/${archive}" -C /tmp/syft; \
    install -m 0755 /tmp/syft/syft /usr/local/bin/syft; \
    cp /tmp/syft/LICENSE /licenses/syft/LICENSE; \
    rm -rf /tmp/syft "/tmp/${archive}" /tmp/checksums.txt


LABEL org.opencontainers.image.title="syft" \
      org.opencontainers.image.description="Container image with Syft installed"

ENTRYPOINT ["syft"]
CMD ["--help"]
