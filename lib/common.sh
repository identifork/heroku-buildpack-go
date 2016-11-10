#!/bin/bash

# -----------------------------------------
# load environment variables
# allow apps to specify cgo flags. The literal text '${build_dir}' is substituted for the build directory

godepsJSON="${build}/Godeps/Godeps.json"
vendorJSON="${build}/vendor/vendor.json"
glideYAML="${build}/glide.yaml"

steptxt="----->"
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m' # No Color
CURL="curl -s -L --retry 15 --retry-delay 2" # retry for up to 30 seconds

warn() {
    echo -e "${YELLOW} !!    $@${NC}"
}

err() {
    echo -e >&2 "${RED} !!    $@${NC}"
}

step() {
    echo "$steptxt $@"
}

start() {
    echo -n "$steptxt $@... "
}

finished() {
    echo "done"
}

loadEnvDir() {
    local env_dir="${1}"
    if [ ! -z "${env_dir}" ]
    then
        mkdir -p "${env_dir}"
        env_dir=$(cd "${env_dir}/" && pwd)
        for key in CGO_CFLAGS CGO_CPPFLAGS CGO_CXXFLAGS CGO_LDFLAGS GO_LINKER_SYMBOL GO_LINKER_VALUE GO15VENDOREXPERIMENT GOVERSION GO_INSTALL_PACKAGE_SPEC GO_INSTALL_TOOLS_IN_IMAGE GO_SETUP_GOPATH_IN_IMAGE
        do
            if [ -f "${env_dir}/${key}" ]
            then
                export "${key}=$(cat "${env_dir}/${key}" | sed -e "s:\${build_dir}:${build}:")"
            fi
        done
    fi
}

setGoVersionFromEnvironment() {
  if test -z "${GOVERSION}"
  then
    warn ""
    warn "'GOVERSION' isn't set, defaulting to '${DefaultGoVersion}'"
    warn ""
    warn "Run 'heroku config:set GOVERSION=goX.Y' to set the Go version to use"
    warn "for future builds"
    warn ""
  fi
  ver=${GOVERSION:-$DefaultGoVersion}
}

determineTool() {
  setGoVersionFromEnvironment
}
