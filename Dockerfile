FROM docker:24.0.6-cli-alpine3.18 as base

ARG TARGETARCH

ENV HELM_RELEASE_TAG=v3.16.4 \
    KUBECTL_VERSION=v1.32.2 \
    K3D_RELEASE_TAG=v5.8.3 \
    SPRUCE_VERSION=v1.31.1 \
    STERN_VERSION=1.31.0 \
    CRANE_VERSION=v0.20.2 \
    MANIFEST_TOOL_VERSION=2.1.9 \
    BABASHKA_RELEASE=1.12.196

WORKDIR /build

COPY build/* /tmp/
RUN /tmp/install.sh && rm /tmp/install.sh

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/node_modules/.bin

RUN set -eux \
    && crane version \
    && sort --version \
    && helm version --client \
    && echo -e "v1.0.0\nv0.9.9" | sort --version-sort \
    && spruce -v
