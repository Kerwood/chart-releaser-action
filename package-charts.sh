#!/usr/bin/env bash
set -o errexit
set -o pipefail

usage() {
 echo "Usage: $0 [OPTIONS]"
 echo "Options:"
 echo " -h, --help         Display this help message"
 echo " -c, --charts-dir   The root folder containing all charts, DEFAULT '.'"
}

CHARTS_DIR="."

while [ $# -gt 0 ] ; do
  case $1 in
    -c | --charts-dir) CHARTS_DIR="$2"; shift 2 ;;
    -h | --help) usage; exit 1 ;;
    *)
      echo "Invalid option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

# File all Helm Charts
CHART_PATHS=$(find "$CHARTS_DIR" -name Chart.yaml -type f -exec dirname {} +)

echo "##############################################"
echo "Charts found:"
echo "$CHART_PATHS"
echo "##############################################"
#
# Foreach Helm Chart, get the name and version.
# If the composite tag does not exist, create a package with chart-releaser.
for C_PATH in $CHART_PATHS; do
    VERSION=$(helm show chart "$C_PATH" 2>/dev/null | yq eval '.version' -)
    NAME=$(helm show chart "$C_PATH" 2>/dev/null | yq eval '.name' -)
    TAG="$NAME-$VERSION"
    if [ ! "$(git tag -l "$TAG")" ]; then
      cr package "$C_PATH"
    else
      echo "Skipping $NAME-$VERSION.."
    fi
done
