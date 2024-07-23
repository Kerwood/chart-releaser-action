# Helm Chart Releaser Action

This action uses the [Chart Releaser](https://github.com/helm/chart-releaser) tool from Helm to find Charts within your repository, package them, release them as artifacts on a Github release and update the `index.yaml` in your Github Pages branch (default `gh-pages`), making your repository a self contained Helm Chart repository.

This action is heavily inspired from the official [Chart Releaser Action](https://github.com/helm/chart-releaser-action) from Helm. The offical action is using `git` voodoo to determine which charts in a given directory should be packaged, which has it's limitations, like finding charts in Submodules.

This action will find all directories and subdirectories containing a `Chart.yaml` file and treats them as a Helm chart to package. By default it will skip packaging a chart if the chart version already exists as a git tag.

## Pre-requisites

1. A GitHub repo containing a directory with your Helm charts, default is `./charts`.
1. A branch setup as your Github Pages branch to store the `index.yaml` file, default `gh-pages`.
1. Create a workflow `.yaml` file in your `.github/workflows` directory. An [example workflow](#example-workflow) is available below.

## Inputs

- `github_token`: The pipeline access token, required.
- `version`: The chart-releaser version to use, optional, default: `v1.6.1`.
- `charts_dir`: The charts directory, optional, default `./charts`.
- `mark_as_latest`: Will mark the created GitHub release as latest, optional, default `true`.
- `pages_branch`: Name of the branch setup as Github pages branch to push the `index.yaml` file to.

## Example Workflow

```yaml
name: Chart Releaser

on:
  workflow_dispatch:
  push:
    branches:
      - main
    paths:
      - "**/Chart.yaml"

jobs:
  chart-releaser:
    name: Chart Releaser
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Configure Git
        run: |
          git config --local user.name "$GITHUB_ACTOR"
          git config --local user.email "$GITHUB_ACTOR@users.noreply.github.com"

      - name: Install Helm
        uses: azure/setup-helm@v4

      - name: Run chart-releaser
        uses: kerwood/chart-releaser-action@v1
        with:
          github_token: "${{ secrets.GITHUB_TOKEN }}"
```
