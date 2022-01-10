#!/usr/bin/env bash
# Package tree used for installing netdata on distribution:
# << opeSUSE >>
# supported versions: leap/15.3 and tumbleweed
# it may work with SLES as well, although we have not tested with it
# shellcheck disable=SC2068,SC2086,SC1090

set -e

PROGRAM="$0"
INSTALLER_DIR="$(dirname "${PROGRAM}")"

source "${INSTALLER_DIR}/../functions.sh"

NON_INTERACTIVE=0
export DONT_WAIT=0

check_flags ${@}

declare -a package_tree=(
  gcc
  gcc-c++
  make
  autoconf
  autoconf-archive
  autogen
  automake
  libtool
  pkg-config
  cmake
  netcat-openbsd
  zlib-devel
  libuuid-devel
  libmnl-devel
  libjson-c-devel
  libuv-devel
  liblz4-devel
  libopenssl-devel
  judy-devel
  libelf-devel
  git
  tar
  curl
  gzip
  python3
)

packages_to_install=

for package in ${package_tree[@]}; do
  if zypper search -i $package &> /dev/null; then
    echo "Package '${package}' is installed"
  else
    echo "Package '$package' is NOT installed"
    packages_to_install="$packages_to_install $package"
  fi
done

if [[ -z $packages_to_install ]]; then
  echo "All required packages are already installed. Skipping .."
else
  echo "packages_to_install:" ${packages_to_install[@]}
  opts="--ignore-unknown"
  if [ "${NON_INTERACTIVE}" -eq 1 ]; then
    echo >&2 "Running in non-interactive mode"
    opts="--non-interactive"
  fi
  zypper ${opts} install ${packages_to_install[@]}
fi
