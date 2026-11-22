#!/usr/bin/env bash
# First publish (and later releases) of Sticker Pop to GitHub. Run on your Mac:
#
#   bash tools/publish.sh
#
# It: checks versions, commits everything, creates github.com/stupidly-logical/sticker-pop
# (public) if needed, pushes main, turns on GitHub Pages (built by Actions),
# and pushes the version tag. The tag triggers the Release workflow; the push
# to main triggers the Docs workflow. Needs git, and the GitHub CLI (`gh`) for
# creating the repo and enabling Pages (brew install gh && gh auth login).
set -euo pipefail
cd "$(dirname "$0")/.."

OWNER=stupidly-logical
REPO=sticker-pop
VERSION="$(tr -d '[:space:]' < VERSION)"
TAG="v$VERSION"
DOCS="https://$OWNER.github.io/$REPO/"

echo "== Sticker Pop $TAG"
node tools/version.mjs sync >/dev/null   # package copies of LICENSE and CHANGELOG.md
node tools/check-version.mjs --tag "$TAG"

if git rev-parse -q --verify "refs/tags/$TAG" >/dev/null 2>&1; then
  echo "Tag $TAG already exists. Bump it first: node tools/version.mjs patch|minor|major"
  exit 1
fi

echo "== Commit"
[ -d .git ] || git init -q -b main
git add -A
if ! git diff --cached --quiet; then
  git commit -q -m "Sticker Pop $TAG"
  echo "committed $(git rev-parse --short HEAD)"
else
  echo "nothing new to commit"
fi

echo "== GitHub repo"
if command -v gh >/dev/null; then
  gh auth status >/dev/null 2>&1 || { echo "Run: gh auth login   (then run this script again)"; exit 1; }
  if ! gh repo view "$OWNER/$REPO" >/dev/null 2>&1; then
    gh repo create "$OWNER/$REPO" --public \
      --description "Sticker Pop: a bold, sticker-style design system for Compose, Flutter, SwiftUI and the web" \
      --homepage "$DOCS"
  fi
else
  echo "GitHub CLI not found. Create an empty public repo named $REPO at https://github.com/new"
  read -r -p "Press Enter once it exists… "
fi
git remote get-url origin >/dev/null 2>&1 || git remote add origin "git@github.com:$OWNER/$REPO.git"

echo "== Push main"
git push -u origin main

echo "== GitHub Pages (built by Actions)"
if command -v gh >/dev/null; then
  gh api -X POST "repos/$OWNER/$REPO/pages" -f build_type=workflow >/dev/null 2>&1 \
    || gh api -X PUT "repos/$OWNER/$REPO/pages" -f build_type=workflow >/dev/null 2>&1 \
    || echo "Couldn't switch Pages on; do it in Settings › Pages › Source: GitHub Actions"
  # The first Docs run may have started before Pages was on: run it again.
  gh workflow run docs.yml --ref main >/dev/null 2>&1 || true
else
  echo "In the repo: Settings › Pages › Source: GitHub Actions, then Actions › Docs › Run workflow"
fi

echo "== Tag $TAG"
git tag -a "$TAG" -m "Sticker Pop $TAG"
git push origin "$TAG"

cat <<DONE

Done.
  Repo:     https://github.com/$OWNER/$REPO
  Actions:  https://github.com/$OWNER/$REPO/actions   (CI, Docs, Release)
  Docs:     $DOCS   (live once the Docs workflow finishes, ~5 minutes)
  Release:  https://github.com/$OWNER/$REPO/releases/tag/$TAG

The first CI run records Compose and SwiftUI screenshot references; download
them from the run's artifacts and commit them so later runs compare against them.
DONE
