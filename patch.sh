# @author Ninh Pham. All rights reserved.

set -eo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

cout() {
  printf "%b\n" "$@$NC"
}

revanced_cli=revanced-cli.jar
revanced_patches=revanced-patches.jar
revanced_integrations=revanced-integrations.apk

downloader="aria2c --log-level error --console-log-level=error --file-allocation=none -x 16 -s 1"

dl() {
  local artifact=$1
  local output=$2
  if [ -f "$output" ]; then
    return 0
  fi

  cout "${CYAN}Downloading revanced/$artifact"
  link=$(./gh_dl_link.sh revanced/$artifact $artifact-)

  $downloader "$link" -o $output
}

main() {
  dl revanced-cli $revanced_cli
  dl revanced-patches $revanced_patches
  dl revanced-integrations $revanced_integrations

  if [ -z "$patch_target" ]; then
    patch_target=youtube
  fi

  source <(./apk_dl $patch_target"_compatible")
  apk_version=$APK_VERSION
  apk_link=$APK_URL
  apk_filename=$patch_target-$apk_version.apk

  output_apk=revanced-${patch_target#*-}-$apk_version.apk

  cout "${YELLOW}$patch_target version to be patched : $apk_version"
  cout "Downloading stock apk: $apk_link"
  $downloader "$apk_link" -o $apk_filename

  cout "${YELLOW}Patching in progress"

  java -jar $revanced_cli \
    --apk $apk_filename \
    --out $output_apk \
    --clean \
    --bundle $revanced_patches \
    --merge $revanced_integrations $patch_args
}

main
