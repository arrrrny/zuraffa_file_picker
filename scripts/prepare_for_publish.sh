#!/bin/bash
set -e
# Adopted from the zikzak_inappwebview publish pipeline (publish-manager flow).

GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

PACKAGES=("zuraffa_file_picker" "zuraffa_file_picker_platform_interface" "zuraffa_file_picker_android" "zuraffa_file_picker_ios" "zuraffa_file_picker_macos")

if [ "$#" -eq 0 ]; then
    APP_DIR="$(cd "$(dirname "$0")/.." >/dev/null 2>&1; pwd -P)/packages/zuraffa_file_picker"
    VERSION=$(grep "^version:" "$APP_DIR/pubspec.yaml" | sed 's/version: //' | tr -d '[:space:]')
    [ -z "$VERSION" ] && echo -e "${RED}Usage: $0 <version>${NC}" && exit 1
else
    VERSION=$1
fi
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}Version must be semver (X.Y.Z)${NC}"; exit 1
fi
BRANCH="publish-$VERSION"
ROOT_DIR="$(pwd)"
cd "$ROOT_DIR"

git diff --quiet || { echo -e "${RED}Working tree is dirty - commit or stash first.${NC}"; exit 1; }
git checkout -b "$BRANCH" 2>/dev/null || { echo -e "${RED}Branch $BRANCH already exists${NC}"; exit 1; }
echo -e "${GREEN}Created branch $BRANCH${NC}"

# Bump every package version and align in-family constraints to ^VERSION.
for pkg in "${PACKAGES[@]}"; do
    pubspec="packages/$pkg/pubspec.yaml"
    sed -i '' -E "s/^version: .*/version: $VERSION/" "$pubspec"
    sed -i '' -E "/^( *zuraffa_file_picker: \^)/s|.*|  zuraffa_file_picker: ^$VERSION|" "$pubspec"
    sed -i '' -E "/^( *zuraffa_file_picker_platform_interface: \^)/s|.*|  zuraffa_file_picker_platform_interface: ^$VERSION|" "$pubspec"
    echo -e "${BLUE}$pkg -> $VERSION (in-family deps ^$VERSION)${NC}"
done

# Propagate the root CHANGELOG entry for this version into every package
# CHANGELOG (write the entry into the root CHANGELOG.md before running this
# script; otherwise a minimal entry is generated).
ENTRY=""
[ -f CHANGELOG.md ] && ENTRY=$(awk -v v="$VERSION" 'BEGIN{p=0} /^## /{{if (p) exit} if ($0 ~ "^## " v) p=1} p{{print}}' CHANGELOG.md)
if [ -z "$ENTRY" ]; then
    LAST_SUBJECT=$(git log -1 --pretty=%s)
    ENTRY="## $VERSION

- $LAST_SUBJECT"
fi
for pkg in "${PACKAGES[@]}"; do
    f="packages/$pkg/CHANGELOG.md"
    grep -q "^## $VERSION" "$f" && continue
    printf '%s\n\n' "$ENTRY" | cat - "$f" > "$f.tmp" && mv "$f.tmp" "$f"
done

git add -A
git commit -q -m "Prepare for publishing version $VERSION"
echo -e "${GREEN}Committed publish prep for $VERSION on $BRANCH.${NC}"
echo "Next: bash scripts/publish.sh"
