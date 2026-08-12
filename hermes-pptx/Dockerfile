# hermes-pptx — Hermes Agent + top-tier PowerPoint toolchain
# Extends official Nous Hermes with LibreOffice visual QA, pptxgenjs, OfficeCLI.
FROM nousresearch/hermes-agent:latest

USER root

ARG OFFICECLI_VERSION=1.0.143
ARG TARGETARCH=amd64

ENV DEBIAN_FRONTEND=noninteractive \
    PLAYWRIGHT_BROWSERS_PATH=/opt/hermes/.playwright \
    NODE_PATH=/opt/pptx-tools/node_modules

# System packages for native PPTX generation + Anthropic-style visual QA loop
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

# Node tooling used by Anthropic pptx skill
RUN mkdir -p /opt/pptx-tools \
 && cd /opt/pptx-tools \
 && npm init -y >/dev/null \
 && npm install pptxgenjs@^3.12.0 \
 && npm cache clean --force \
 && node -e "require('pptxgenjs'); console.log('pptxgenjs ok')"

# Python packages in Hermes venv (markitdown read path + validation deps)
RUN uv pip install --python /opt/hermes/.venv/bin/python \
      'markitdown[pptx]' \
      Pillow \
      defusedxml \
      lxml \
      python-pptx \
 && /opt/hermes/.venv/bin/python -c "import markitdown, pptx, PIL; print('python pptx stack ok')"

# OfficeCLI — download release binary (no secrets / no vendored binary in git)
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

# Convenience wrappers on PATH for the agent
COPY scripts/pptx-render.sh /usr/local/bin/pptx-render
COPY scripts/pptx-qa.sh /usr/local/bin/pptx-qa
RUN chmod 755 /usr/local/bin/pptx-render /usr/local/bin/pptx-qa \
 && ln -sf /opt/hermes/.venv/bin/python /usr/local/bin/hermes-python \
 && printf '%s\n' '#!/bin/sh' 'exec /opt/hermes/.venv/bin/python "$@"' > /usr/local/bin/pptx-python \
 && chmod 755 /usr/local/bin/pptx-python

# Optional baked skill copies (runtime skills live in ./data via volume)
COPY data/skills/productivity/deck-master /opt/hermes-pptx/skills/deck-master
COPY data/skills/office/officecli /opt/hermes-pptx/skills/officecli

WORKDIR /opt/hermes
