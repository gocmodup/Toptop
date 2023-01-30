# @author Ninh Pham. All rights reserved.

set -eo pipefail

repo=$1
filter=$2
releases=$(curl --fail https://api.github.com/repos/$repo/releases/latest -s)
url=$(jq -r '[.assets[] | select(.name | contains("'"$filter"'"))][0] | .url' <<<$releases)
version=$(jq -r '.name' <<<$releases)

echo "$repo: $version" 1>&2

if [ "$url" == "null" ]; then
  echo "No url found for filter: $filter"
  exit 1
fi
echo "$url" 1>&2

/usr/bin/curl --fail -LIso /dev/null -w '%{url_effective}\n' -H 'accept: application/octet-stream' "$url"
