#!/bin/sh

set -eux;

apk add --update --no-cache \
  bash \
  ca-certificates \
  coreutils \
  curl \
  git \
  jq \
  make \
  openssh-client \
  openssl \
  python3 \
  py-pip \
  npm \
  xmlstarlet \
  openjdk11-jre-headless \
  ansible \
  gcompat \
  ;
  
npm install -g semver
update-ca-certificates

pip install \
      yb-cassandra-driver \
      kubernetes \
      passlib \
      ;

#==============================================================
# Helm - https://github.com/helm/helm/releases
#==============================================================
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh --version ${HELM_RELEASE_TAG}
rm get_helm.sh

#==============================================================
# Kubectl - https://kubernetes.io/releases/
#==============================================================
curl -L https://dl.k8s.io/${KUBECTL_VERSION}/kubernetes-client-linux-${TARGETARCH}.tar.gz | tar -zxv --strip-components=3 kubernetes/client/bin/kubectl -C /usr/local/bin

#==============================================================
# K3D - https://github.com/k3d-io/k3d/releases
#==============================================================
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=${K3D_RELEASE_TAG} bash

#==============================================================
# Spruce - https://github.com/geofffranks/spruce/releases
#==============================================================
curl -L https://github.com/geofffranks/spruce/releases/download/${SPRUCE_VERSION}/spruce-linux-${TARGETARCH} > /usr/local/bin/spruce
chmod 755 /usr/local/bin/spruce

#==============================================================
# Stern - https://github.com/stern/stern/releases
#==============================================================
curl -L https://github.com/stern/stern/releases/download/v${STERN_VERSION}/stern_${STERN_VERSION}_linux_${TARGETARCH}.tar.gz  | tar -xzf - -C /usr/local/bin
chmod 755 /usr/local/bin/stern

#==============================================================
# Crane - https://github.com/google/go-containerregistry/releases
#==============================================================
CRANEARCH=x86_64
if [ "$TARGETARCH" == "arm64" ]; then
    CRANEARCH=arm64
fi;
    
curl -L https://github.com/google/go-containerregistry/releases/download/${CRANE_VERSION}/go-containerregistry_Linux_${CRANEARCH}.tar.gz | tar -xzf - -C /usr/local/bin crane

#==============================================================
# Manifest Tool - https://github.com/estesp/manifest-tool/releases
#==============================================================
curl -L https://github.com/estesp/manifest-tool/releases/download/v${MANIFEST_TOOL_VERSION}/binaries-manifest-tool-${MANIFEST_TOOL_VERSION}.tar.gz | tar -xzf - -C /usr/local/bin
ls /usr/local/bin/manifest-tool* | grep -v linux-${TARGETARCH} | xargs rm
ln -s /usr/local/bin/manifest-tool-linux-${TARGETARCH} /usr/local/bin/manifest-tool

#==============================================================
# Babashka - https://github.com/babashka/babashka/releases
#==============================================================
BBARCH=amd64
if [ "$TARGETARCH" == "arm64" ]; then
    BBARCH=aarch64
fi;

curl -L https://github.com/babashka/babashka/releases/download/v${BABASHKA_RELEASE}/babashka-${BABASHKA_RELEASE}-linux-${BBARCH}-static.tar.gz | tar -xzf - -C /usr/local/bin

kubectl version --client=true
k3d --version
spruce -v
stern --version
crane version
manifest-tool --version
bb --version

sort --version
echo -e "v1.0.0\nv0.9.9" | sort --version-sort
echo -e '#!/bin/sh\nsha1sum "$@"' > /usr/local/bin/shasum && chmod +x /usr/local/bin/shasum
