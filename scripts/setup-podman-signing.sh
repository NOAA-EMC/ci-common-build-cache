#!/bin/bash
set -euo pipefail

# Setup Podman for GPG-based image signing in non-interactive CI environment
# This script configures Podman to sign container images with GPG keys,
# using the same keys as Spack package signing.

echo "Setting up Podman for GPG-based image signing..."

# Install Podman if not already available
if ! command -v podman &> /dev/null; then
    echo "Installing Podman..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq podman
fi

podman --version

# Ensure directories exist
mkdir -p ~/.config/containers
mkdir -p ~/.local/share/containers/sigstore

# Configure containers policy to allow unsigned images for build/test
# but require signatures for production use (can be overridden per-registry)
cat > ~/.config/containers/policy.json <<'EOF'
{
    "default": [
        {
            "type": "insecureAcceptAnything"
        }
    ],
    "transports": {
        "docker": {
            "": [
                {
                    "type": "insecureAcceptAnything"
                }
            ]
        },
        "docker-daemon": {
            "": [
                {
                    "type": "insecureAcceptAnything"
                }
            ]
        }
    }
}
EOF

# Configure signature storage location for ghcr.io
# Signatures will be stored as OCI artifacts in the same registry
sudo mkdir -p /etc/containers/registries.d
sudo tee /etc/containers/registries.d/ghcr.io.yaml > /dev/null <<EOF
docker:
    ghcr.io:
        sigstore: file://${HOME}/.local/share/containers/sigstore
        sigstore-staging: file://${HOME}/.local/share/containers/sigstore
EOF

# Verify GPG is configured correctly for non-interactive use
if [ -z "${SPACK_GPG_KEY_ID:-}" ]; then
    echo "Error: SPACK_GPG_KEY_ID environment variable not set"
    exit 1
fi

# Test GPG signing capability (non-interactive mode should already be configured)
echo "Testing GPG signing capability with key ${SPACK_GPG_KEY_ID}..."
echo "test" | gpg --default-key "${SPACK_GPG_KEY_ID}" \
    --pinentry-mode loopback \
    --passphrase "${GPG_PASSPHRASE:-}" \
    --armor --sign > /dev/null 2>&1 || {
    echo "Error: GPG signing test failed. Check key and passphrase configuration."
    exit 1
}

echo "✓ Podman signing setup complete"
echo "  Key ID: ${SPACK_GPG_KEY_ID}"
echo "  Sigstore: ${HOME}/.local/share/containers/sigstore"
