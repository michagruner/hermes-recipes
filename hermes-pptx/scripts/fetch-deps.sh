#!/usr/bin/env bash
# Download third-party skills (not vendored: licenses / size).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

OFFICECLI_VERSION="${OFFICECLI_VERSION:-1.0.143}"
PPTX_SKILL_DIR="data/skills/document/pptx"
OFFICECLI_SKILL_DIR="data/skills/office/officecli"

echo "== fetch OfficeCLI skill =="
mkdir -p "$OFFICECLI_SKILL_DIR"
if [[ ! -f "$OFFICECLI_SKILL_DIR/SKILL.md" ]]; then
  curl -fsSL -o "$OFFICECLI_SKILL_DIR/SKILL.md" "https://officecli.ai/SKILL.md" \
    || curl -fsSL -o "$OFFICECLI_SKILL_DIR/SKILL.md" \
         "https://raw.githubusercontent.com/iOfficeAI/OfficeCLI/main/SKILL.md"
fi
echo "  $OFFICECLI_SKILL_DIR/SKILL.md"

echo "== fetch Anthropic pptx skill =="
if [[ ! -f "$PPTX_SKILL_DIR/SKILL.md" ]]; then
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  git clone --depth 1 https://github.com/anthropics/skills.git "$TMP/anthropic-skills"
  mkdir -p "$(dirname "$PPTX_SKILL_DIR")"
  cp -a "$TMP/anthropic-skills/skills/pptx" "$PPTX_SKILL_DIR"
  echo "  installed from anthropics/skills (see $PPTX_SKILL_DIR/LICENSE.txt)"
else
  echo "  already present: $PPTX_SKILL_DIR"
fi

echo "== optional host officecli binary (image downloads its own) =="
mkdir -p bin
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64|amd64) OC_ARCH=linux-x64 ;;
  aarch64|arm64) OC_ARCH=linux-arm64 ;;
  *) OC_ARCH="" ;;
esac
if [[ -n "$OC_ARCH" && ! -x bin/officecli ]]; then
  curl -fsSL -o bin/officecli \
    "https://github.com/iOfficeAI/OfficeCLI/releases/download/v${OFFICECLI_VERSION}/officecli-${OC_ARCH}" \
    && chmod +x bin/officecli \
    && echo "  bin/officecli $(./bin/officecli --version 2>/dev/null || true)" \
    || echo "  (skip host officecli download)"
fi

mkdir -p workspace/decks workspace/tmp projects data/cache
echo "OK — deps ready"
