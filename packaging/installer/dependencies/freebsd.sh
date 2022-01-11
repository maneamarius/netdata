#!/usr/bin/env bash
# Package tree used for installing netdata on distribution:
# << FreeBSD  >>
# shellcheck disable=SC2068,SC2086,SC2002,SC1090,SC1091

set -e

PROGRAM="$0"
INSTALLER_DIR="$(dirname "${PROGRAM}")"

source "${INSTALLER_DIR}/../functions.sh"

NON_INTERACTIVE=0
export DONT_WAIT=0

check_flags ${@}

package_tree="
  git
  gcc
  autoconf
  autoconf-archive
  autogen
  automake
  libtool
  pkgconf
  cmake
  curl
  gzip
  netcat
  lzlib
  e2fsprogs-libuuid
  json-c
  libuv
  liblz4
  openssl
  Judy
  python3
  "
validate_tree_freebsd

packages_to_install=

for package in $package_tree; do
  if pkg info -Ix $package &> /dev/null; then
    echo "Package '${package}' is installed"
  else
    echo "Package '${package}' is NOT installed"
    packages_to_install="$packages_to_install $package"
  fi
done

if [[ -z "$packages_to_install" ]]; then
  echo "All required packages are already installed. Skipping .."
else
  echo "packages_to_install:" $packages_to_install
  opts=
  if [ "${NON_INTERACTIVE}" -eq 1 ]; then
    echo >&2 "Running in non-interactive mode"
    opts="-y"
  fi
  pkg install ${opts} $packages_to_install
fi
