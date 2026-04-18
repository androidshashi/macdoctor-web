#!/usr/bin/env bash
set -euo pipefail

BINARY_URL="https://raw.githubusercontent.com/androidshashi/macdoctor/main/macdoctor"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="macdoctor"
TMP_FILE="$(mktemp)"

cleanup() {
  rm -f "$TMP_FILE"
}
trap cleanup EXIT

# ── OS check ────────────────────────────────────────────────────────────────
if [ "$(uname -s)" != "Darwin" ]; then
  echo "❌  MacDoctor is macOS-only. Detected OS: $(uname -s)"
  exit 1
fi

# ── Arch detection ───────────────────────────────────────────────────────────
ARCH="$(uname -m)"
if [ "$ARCH" != "arm64" ] && [ "$ARCH" != "x86_64" ]; then
  echo "❌  Unsupported architecture: $ARCH"
  exit 1
fi

echo ""
echo "🩺  MacDoctor Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Find what's secretly eating your Mac storage."
echo "  This will install 'macdoctor' to $INSTALL_DIR/$BINARY_NAME"
echo ""

# ── Confirmation ─────────────────────────────────────────────────────────────
# Read from /dev/tty explicitly so this works when piped through: curl ... | bash
read -r -p "  Proceed with installation? [y/N] " CONFIRM </dev/tty

case "$CONFIRM" in
  [yY][eE][sS]|[yY]) ;;
  *)
    echo ""
    echo "  Installation cancelled."
    exit 0
    ;;
esac

echo ""
echo "  ⬇️  Downloading macdoctor..."

if ! curl -fsSL "$BINARY_URL" -o "$TMP_FILE"; then
  echo ""
  echo "  ❌  Download failed. Check your internet connection and try again."
  exit 1
fi

if [ ! -s "$TMP_FILE" ]; then
  echo ""
  echo "  ❌  Downloaded file is empty. The release binary may not be available yet."
  exit 1
fi

# ── Sanity-check: must look like a Mach-O binary (macOS executable magic bytes)
FILE_TYPE="$(file "$TMP_FILE")"
if ! echo "$FILE_TYPE" | grep -qiE "mach-o|executable|shell script"; then
  echo ""
  echo "  ❌  Downloaded file does not appear to be a valid executable."
  echo "      Got: $FILE_TYPE"
  exit 1
fi

chmod +x "$TMP_FILE"

echo "  🔐  Moving to $INSTALL_DIR (may require sudo)..."

if [ -w "$INSTALL_DIR" ]; then
  mv "$TMP_FILE" "$INSTALL_DIR/$BINARY_NAME"
else
  sudo mv "$TMP_FILE" "$INSTALL_DIR/$BINARY_NAME"
fi

echo ""
echo "  ✅  macdoctor installed successfully!"
echo ""
echo "  Run it now:"
echo "     macdoctor"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
