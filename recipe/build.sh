#!/usr/bin/env bash
set -euxo pipefail
IFS=$'\n\t'

# The go-cgo activation points GOPATH at the source root, but the ipsw module
# is extracted directly into $SRC_DIR -- Go refuses to run with a go.mod at the
# GOPATH root. Keep GOPATH (and the build cache) out of the module tree.
export GOPATH="${SRC_DIR}/_gopath"
export GOCACHE="${SRC_DIR}/_gocache"
mkdir -p "${GOPATH}" "${GOCACHE}"

# Enable CGO for native library support
export GOFLAGS="${GOFLAGS:-} -mod=readonly"

# Set up pkg-config for finding libraries
export CGO_CFLAGS="-I${PREFIX}/include"
export CGO_CXXFLAGS=""
export CGO_LDFLAGS="-L${PREFIX}/lib"

# Build version info
COMMIT="conda-forge-${PKG_VERSION}"

# Build ipsw with version information embedded
go build \
    -ldflags "-s -w \
        -X github.com/blacktop/ipsw/cmd/ipsw/cmd.AppVersion=${PKG_VERSION} \
        -X github.com/blacktop/ipsw/cmd/ipsw/cmd.AppBuildCommit=${COMMIT}" \
    -o "${PREFIX}/bin/ipsw" \
    ./cmd/ipsw

# Verify the binary was built
"${PREFIX}/bin/ipsw" version
