#!/usr/bin/env bash
set -o errexit
set -o pipefail

usage() {
 echo "Usage: $0 [OPTIONS]"
 echo "Options:"
 echo " -h, --help         Display this help message"
 echo " -c, --cr-version   Chart Releaser version eg. v1.6.1, REQUIRED"
}

while [ $# -gt 0 ] ; do
  case $1 in
    -c | --cr-version) CR_VERSION="$2"; shift 2 ;;
    -h | --help) usage; exit 1 ;;
    *)
      echo "Invalid option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [ -z "$CR_VERSION" ]; then
  echo -e "\nThe argument --cr-version is requried.\n"
  usage
  exit 1
fi

echo "Downloading chart-releaser..."

curl -sSLo cr.tar.gz "https://github.com/helm/chart-releaser/releases/download/$CR_VERSION/chart-releaser_${CR_VERSION#v}_linux_amd64.tar.gz"
tar -xzf cr.tar.gz cr
rm -f cr.tar.gz

echo "Chart Releaser $CR_VERSION downloaded successfully"
