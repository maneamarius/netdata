#!/usr/bin/env bash
# Package tree used for installing netdata on distribution:
# << Rocky Linux >>
# supported version: 8.5
# shellcheck disable=SC2068,SC2086,SC2002,SC2154,SC1090,SC1091

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
  pkgconfig
  cmake
  nmap-ncat
  zlib-devel
  libuuid-devel
  libmnl-devel
  json-c-devel
  libuv-devel
  lz4-devel
  openssl-devel
  python3
  elfutils-libelf-devel
  git
  tar
  curl
  gzip
)

validate_tree_rockylinux() {
  local opts=
  if [ "${NON_INTERACTIVE}" -eq 1 ]; then
    echo >&2 "Running in non-interactive mode"
    opts="-y"
  fi

  echo >&2 " > Checking for config-manager ..."
  if ! dnf config-manager; then
    if prompt "config-manager not found, shall I install it?"; then
      dnf ${opts} install 'dnf-command(config-manager)'
    fi
  fi

  echo >&2 " > Checking for PowerTools ..."
  if ! dnf repolist | grep PowerTools; then
    if prompt "PowerTools not found, shall I install it?"; then
      dnf ${opts} config-manager --set-enabled powertools || enable_powertools_repo
    fi
  fi

  echo >&2 " > Updating libarchive ..."
  dnf ${opts} install libarchive

  dnf makecache --refresh
}

function enable_powertools_repo {
  if ! dnf repolist | grep -q powertools; then
    cat > /etc/yum.repos.d/powertools.repo <<-EOF
    [powertools]
    name=Rocky Linux $releasever - PowerTools
    mirrorlist=https://mirrors.rockylinux.org/mirrorlist?arch=$basearch&repo=PowerTools-$releasever
    #baseurl=http://dl.rockylinux.org/$contentdir/$releasever/PowerTools/$basearch/os/
    gpgcheck=1
    enabled=1
    gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial
EOF
  else
    echo "Something went wrong!"
    exit 1
  fi
}

validate_tree_rockylinux

packages_to_install=

for package in ${package_tree[@]}; do
  if rpm -q $package &> /dev/null; then
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
  opts=
  if [ "${NON_INTERACTIVE}" -eq 1 ]; then
    echo >&2 "Running in non-interactive mode"
    opts="-y"
  fi
  dnf install ${opts} ${packages_to_install[@]}
fi
