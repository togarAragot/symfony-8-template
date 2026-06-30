#!/usr/bin/env bash

set -e

CERT_FILE="caddy-root.crt"

echo "📦 Extracting Caddy root certificate from Docker..."

docker compose cp caddy:/data/caddy/pki/authorities/local/root.crt "$CERT_FILE"

if [ ! -f "$CERT_FILE" ]; then
  echo "❌ Failed to extract certificate"
  exit 1
fi

OS="$(uname -s)"

echo "🔐 Detected OS: $OS"
echo "🔐 Installing certificate into system trust store..."

case "$OS" in
  Darwin)
    sudo security add-trusted-cert \
      -d -r trustRoot \
      -k /Library/Keychains/System.keychain \
      "$CERT_FILE"
    ;;

  Linux)
    sudo cp "$CERT_FILE" /usr/local/share/ca-certificates/caddy-root.crt
    sudo update-ca-certificates

    if grep -qi microsoft /proc/version 2>/dev/null; then
      echo "🪟 WSL detected — also trusting cert on Windows host..."

      # Copy cert to a real local Windows path (UNC paths break cert import tools)
      cp "$CERT_FILE" "/mnt/c/Windows/Temp/caddy-root.crt"

      # Use certutil instead of Import-Certificate — the latter has a known
      # access-denied bug even when properly elevated.
      TMP_PS1="$(mktemp --suffix=.ps1)"
      cat > "$TMP_PS1" <<EOF
Start-Process certutil -Verb RunAs -Wait -ArgumentList '-addstore -f "Root" "C:\Windows\Temp\caddy-root.crt"'
EOF
      WIN_TMP_PS1="$(wslpath -w "$TMP_PS1")"
      powershell.exe -ExecutionPolicy Bypass -File "$WIN_TMP_PS1"
      rm -f "$TMP_PS1"

      echo "ℹ️  Note: Firefox does not use the Windows certificate. You need to enable it explicitly in Firefox"
    fi
    ;;

  MINGW*|MSYS*|CYGWIN*)
    powershell.exe -Command "Start-Process certutil -Verb RunAs -Wait -ArgumentList '-addstore -f \"Root\" \"$PWD\\$CERT_FILE\"'"
    ;;

  *)
    echo "❌ Unsupported OS: $OS"
    exit 1
    ;;
esac

echo "Cleaning up certificate from project..."

rm -f "./$CERT_FILE"

echo "✅ Done. Caddy root CA is trusted on this machine."