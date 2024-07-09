#!/usr/bin/env bash
set -o errexit
set -o pipefail

usage() {
 echo "Usage: $0 [OPTIONS]"
 echo "Options:"
 echo " -h, --help                    Display this help message"
 echo " -r, --repository string       Owner/repository eg. octocat/Hello-World. Provided be the GITHUB_REPOSITORY variable, REQUIRED"
 echo " -t, --token string            GitHub Auth Token, REQUIRED"
 echo " -p, --pages-branch string     The GitHub pages branch, DEFAULT gh-pages"
}

GITHUB_REPOSITORY=
GITHUB_TOKEN=
PAGES_BRANCH=

while [ $# -gt 0 ] ; do
  case $1 in
    -r | --repository) GITHUB_REPOSITORY="$2"; shift 2 ;;
    -t | --token) GITHUB_TOKEN="$2"; shift 2 ;;
    -p | --pages-branch) PAGES_BRANCH="$2"; shift 2 ;;
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

ARGS=(--owner "$OWNER" --git-repo "$REPO" --token "$GITHUB_TOKEN" --push)

if [[ -n "$PAGES_BRANCH" ]]; then
  ARGS+=(--pages-branch "$PAGES_BRANCH")
fi

mkdir -p .cr-index

echo 'Updating charts index...'
cr index "${ARGS[@]}"
