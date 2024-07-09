#!/usr/bin/env bash
set -o errexit
set -o pipefail

usage() {
 echo "Usage: $0 [OPTIONS]"
 echo "Options:"
 echo " -h, --help                         Display this help message"
 echo " -r, --repository string            Owner/repository eg. octocat/Hello-World. Provided be the GITHUB_REPOSITORY variable, REQUIRED"
 echo " -t, --token string                 GitHub Auth Token, REQUIRED"
 echo " -g, --generate-release-notes bool  Automatically generate the name and body for this release, DEFAULT true"
 echo " -m, --make-release-latest bool     Mark the created GitHub release as 'latest', DEFAULT true"
}

GITHUB_REPOSITORY=
GITHUB_TOKEN=
GENERATE_NOTES=true
MARK_AS_LATEST=true

while [ $# -gt 0 ] ; do
  case $1 in
    -r | --repository) GITHUB_REPOSITORY="$2"; shift 2 ;;
    -t | --token) GITHUB_TOKEN="$2"; shift 2 ;;
    -g | --generate-release-notes) GENERATE_NOTES="$2"; shift 2 ;;
    -m | --make-release-latest) MARK_AS_LATEST="$2"; shift 2 ;;
    -h | --help) usage; exit 1 ;;
    *)
      echo "Invalid option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [ -z "$GITHUB_REPOSITORY" ]; then
  echo -e "\nThe argument --repository is requried.\n"
  usage
  exit 1
fi

if [ -z "$GITHUB_TOKEN" ]; then
  echo -e "\nThe argument --token is requried.\n"
  usage
  exit 1
fi

OWNER=$(cut -d '/' -f 1 <<< "$GITHUB_REPOSITORY")
REPO=$(cut -d '/' -f 2 <<< "$GITHUB_REPOSITORY")

ARGS=(--owner "$OWNER" --git-repo "$REPO" --token "$GITHUB_TOKEN" --commit "$(git rev-parse HEAD)" --skip-existing)

if [[ "$GENERATE_NOTES" ]]; then
  ARGS+=(--generate-release-notes)
fi

if [[ ! "$MARK_AS_LATEST" ]]; then
  ARGS+=(--make-release-latest=false)
fi

echo 'Releasing charts...'
cr upload "${ARGS[@]}"
