#!/usr/bin/env bash

set -euo pipefail
export LC_ALL=C

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_GRADLE="$ROOT_DIR/V2rayNG/app/build.gradle.kts"
APP_CONFIG="$ROOT_DIR/V2rayNG/app/src/main/java/com/v2ray/ang/AppConfig.kt"
STRINGS_FILE="$ROOT_DIR/V2rayNG/app/src/main/res/values/strings.xml"
MANIFEST_FILE="$ROOT_DIR/V2rayNG/app/src/main/AndroidManifest.xml"
ICON_SOURCE_DIR="$ROOT_DIR/branding/icons"
TARGET_SOURCE_ROOT="$ROOT_DIR/V2rayNG/app/src/main"

xml_escape() {
    printf '%s' "$1" | sed \
        -e 's/&/\&amp;/g' \
        -e 's/"/\&quot;/g' \
        -e "s/'/\&apos;/g" \
        -e 's/</\&lt;/g' \
        -e 's/>/\&gt;/g'
}

require_file() {
    local path="$1"
    if [[ ! -f "$path" ]]; then
        echo "required file not found: $path" >&2
        exit 1
    fi
}

sanitize_artifact_prefix() {
    local input="$1"
    local sanitized
    sanitized="$(printf '%s' "$input" | tr ' ' '_' | tr -cd 'A-Za-z0-9._-')"
    if [[ -z "$sanitized" ]]; then
        sanitized="custom-v2rayng"
    fi
    printf '%s' "$sanitized"
}

require_file "$APP_GRADLE"
require_file "$APP_CONFIG"
require_file "$STRINGS_FILE"
require_file "$MANIFEST_FILE"

BRAND_APPLICATION_ID="${BRAND_APPLICATION_ID:-com.example.v2rayng}"
BRAND_APP_NAME="${BRAND_APP_NAME:-Custom v2rayNG}"
BRAND_ARTIFACT_PREFIX="${BRAND_ARTIFACT_PREFIX:-$BRAND_APP_NAME}"
BRAND_GITHUB_REPO="${BRAND_GITHUB_REPO:-}"
BRAND_URL_SCHEME="${BRAND_URL_SCHEME:-}"

export BRAND_APPLICATION_ID
export BRAND_APP_NAME_XML="$(xml_escape "$BRAND_APP_NAME")"
export BRAND_ARTIFACT_PREFIX_SAFE="$(sanitize_artifact_prefix "$BRAND_ARTIFACT_PREFIX")"

perl -0pi -e 's/applicationId = "[^"]+"/applicationId = "$ENV{BRAND_APPLICATION_ID}"/g' "$APP_GRADLE"
perl -0pi -e 's/outputFileName = "[^"]+_\$\{variant\.versionName\}/outputFileName = "$ENV{BRAND_ARTIFACT_PREFIX_SAFE}_\${variant.versionName}/g' "$APP_GRADLE"
perl -0pi -e 's#(<string name="app_name"[^>]*>).*?(</string>)#$1$ENV{BRAND_APP_NAME_XML}$2#g' "$STRINGS_FILE"

if [[ -n "$BRAND_GITHUB_REPO" ]]; then
    export BRAND_REPO_URL="https://github.com/$BRAND_GITHUB_REPO"
    export BRAND_REPO_API_URL="https://api.github.com/repos/$BRAND_GITHUB_REPO/releases"
    perl -0pi -e 's#const val APP_URL = "[^"]+"#const val APP_URL = "$ENV{BRAND_REPO_URL}"#g' "$APP_CONFIG"
    perl -0pi -e 's#const val APP_API_URL = "[^"]+"#const val APP_API_URL = "$ENV{BRAND_REPO_API_URL}"#g' "$APP_CONFIG"
    perl -0pi -e 's#const val APP_ISSUES_URL = "\$APP_URL/issues"#const val APP_ISSUES_URL = "$ENV{BRAND_REPO_URL}/issues"#g' "$APP_CONFIG"
fi

if [[ -n "$BRAND_URL_SCHEME" ]]; then
    export BRAND_URL_SCHEME_XML="$(xml_escape "$BRAND_URL_SCHEME")"
    perl -0pi -e 's/android:scheme="[^"]+"/android:scheme="$ENV{BRAND_URL_SCHEME_XML}"/g' "$MANIFEST_FILE"
fi

if [[ -d "$ICON_SOURCE_DIR" ]]; then
    while IFS= read -r source_file; do
        rel_path="${source_file#"$ICON_SOURCE_DIR"/}"
        target_file="$TARGET_SOURCE_ROOT/$rel_path"
        mkdir -p "$(dirname "$target_file")"
        cp "$source_file" "$target_file"
    done < <(find "$ICON_SOURCE_DIR" -type f | sort)
fi

echo "branding applied:"
echo "  applicationId: $BRAND_APPLICATION_ID"
echo "  app name: $BRAND_APP_NAME"
echo "  artifact prefix: $BRAND_ARTIFACT_PREFIX_SAFE"
if [[ -n "$BRAND_GITHUB_REPO" ]]; then
    echo "  release repo: $BRAND_GITHUB_REPO"
fi
if [[ -n "$BRAND_URL_SCHEME" ]]; then
    echo "  url scheme: $BRAND_URL_SCHEME"
fi
