#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LAST_VERSION_FILE="$REPO_ROOT/last_version.txt"

SOURCE_REPO="ollama/ollama"
MIRROR_REPO="Mediatros/MyOlla"
APP_PREFIX="Olla"
SOURCE_APP_NAME="Ollama.app"
SOURCE_ASSET_NAME="Ollama.dmg"

latest_tag=$(gh api "repos/$SOURCE_REPO/releases/latest" --jq '.tag_name')
version="${latest_tag#v}"

last_version=""
if [[ -f "$LAST_VERSION_FILE" ]]; then
  last_version=$(cat "$LAST_VERSION_FILE")
fi

if [[ "$version" == "$last_version" ]]; then
  echo "Déjà à jour (version $version), rien à faire."
  exit 0
fi

echo "Nouvelle version détectée : $version (précédente : ${last_version:-aucune})"

dmg_url=$(gh api "repos/$SOURCE_REPO/releases/tags/$latest_tag" \
  --jq ".assets[] | select(.name == \"$SOURCE_ASSET_NAME\") | .browser_download_url")

if [[ -z "$dmg_url" ]]; then
  echo "Aucun asset $SOURCE_ASSET_NAME trouvé pour $latest_tag" >&2
  exit 1
fi

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

source_dmg="$workdir/$SOURCE_ASSET_NAME"
curl -fsSL "$dmg_url" -o "$source_dmg"

mount_point="$workdir/mount"
mkdir -p "$mount_point"
hdiutil attach "$source_dmg" -nobrowse -mountpoint "$mount_point"

app_name="${APP_PREFIX}_${version}.app"
staging="$workdir/staging"
mkdir -p "$staging"
cp -R "$mount_point/$SOURCE_APP_NAME" "$staging/$app_name"
ln -s /Applications "$staging/Applications"

hdiutil detach "$mount_point" -quiet

out_dmg="$workdir/${APP_PREFIX}_${version}.dmg"
hdiutil create -volname "$APP_PREFIX" -srcfolder "$staging" -ov -format UDZO "$out_dmg"

gh release create "$latest_tag" "$out_dmg" \
  --repo "$MIRROR_REPO" \
  --title "$APP_PREFIX $version" \
  --notes "Mirroir renommé de la release Ollama $latest_tag (binaire macOS uniquement, application renommée). Projet original : https://github.com/ollama/ollama. Licence MIT, voir LICENSE."

echo "$version" > "$LAST_VERSION_FILE"
echo "Release $latest_tag publiée sur $MIRROR_REPO."
