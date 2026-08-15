# hermes-pptx — OSS-only PowerPoint stack on Hermes Agent
# Components: LibreOffice, pptxgenjs (MIT), OfficeCLI (Apache-2.0), python-pptx (MIT)
# No proprietary Anthropic document skills.
FROM nousresearch/hermes-agent:latest

USER root

ARG OFFICECLI_VERSION=1.0.143
ARG TARGETARCH=amd64

ENV DEBIAN_FRONTEND=noninteractive \
    PLAYWRIGHT_BROWSERS_PATH=/opt/hermes/.playwright \
    NODE_PATH=/opt/pptx-tools/node_modules \
    HERMES_WRITE_SAFE_ROOT=/opt/data:/workspace

RUN apt-get -o Acquire::Retries=3 update \
 && apt-get -o Acquire::Retries=3 install -y --no-install-recommends \
      libreoffice-impress \
      libreoffice-draw \
      libreoffice-java-common \
      default-jre-headless \
      poppler-utils \
      fonts-liberation \
      fonts-dejavu-core \
      fonts-dejavu-extra \
      fonts-noto-core \
      fonts-noto-color-emoji \
      fonts-crosextra-carlito \
      fonts-crosextra-caladea \
      fontconfig \
      ca-certificates \
      curl \
      unzip \
      zip \
      imagemagick \
      ghostscript \
 && fc-cache -f \
 && rm -rf /var/lib/apt/lists/* \
 && soffice --version \
 && pdftoppm -v 2>&1 | head -1

RUN mkdir -p /opt/pptx-tools \
 && cd /opt/pptx-tools \
 && npm init -y >/dev/null \
 && npm install pptxgenjs@^3.12.0 \
 && npm cache clean --force \
 && node -e "require('pptxgenjs'); console.log('pptxgenjs ok')"

RUN uv pip install --python /opt/hermes/.venv/bin/python \
      'markitdown[pptx]' \
      Pillow \
      defusedxml \
      lxml \
      python-pptx \
 && /opt/hermes/.venv/bin/python -c "import markitdown, pptx, PIL; print('python pptx stack ok')"

RUN set -e; \
    case "${TARGETARCH}" in \
      amd64|x86_64) ARCH=linux-x64 ;; \
      arm64|aarch64) ARCH=linux-arm64 ;; \
      *) echo "Unsupported arch: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    curl -fsSL -o /usr/local/bin/officecli \
      "https://github.com/iOfficeAI/OfficeCLI/releases/download/v${OFFICECLI_VERSION}/officecli-${ARCH}" \
 && chmod 755 /usr/local/bin/officecli \
 && officecli --version

COPY scripts/pptx-render.sh /usr/local/bin/pptx-render
COPY scripts/pptx-qa.sh /usr/local/bin/pptx-qa
COPY scripts/pptx-validate.sh /usr/local/bin/pptx-validate
RUN chmod 755 /usr/local/bin/pptx-render /usr/local/bin/pptx-qa /usr/local/bin/pptx-validate \
 && ln -sf /opt/hermes/.venv/bin/python /usr/local/bin/hermes-python \
 && printf '%s\n' '#!/bin/sh' 'exec /opt/hermes/.venv/bin/python "$@"' > /usr/local/bin/pptx-python \
 && chmod 755 /usr/local/bin/pptx-python

# Bake OSS skills into image (also mounted live from ./data)
COPY data/skills/productivity/deck-master /opt/hermes-pptx/skills/deck-master
COPY data/skills/productivity/consulting-pptx /opt/hermes-pptx/skills/consulting-pptx
COPY data/skills/productivity/oss-pptx-toolchain /opt/hermes-pptx/skills/oss-pptx-toolchain
COPY data/skills/office/officecli /opt/hermes-pptx/skills/officecli

WORKDIR /opt/hermes
