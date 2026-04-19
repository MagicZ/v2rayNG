# Branding Setup

This repository can build a branded fork of `2dust/v2rayNG` in GitHub Actions without keeping long-lived manual edits in the upstream files.

## Repository Variables

Create these repository variables in GitHub:

- `BRAND_APPLICATION_ID`
  Example: `com.magicz.v2rayngx`
- `BRAND_APP_NAME`
  Example: `V2rayNG X`
- `BRAND_ARTIFACT_PREFIX`
  Example: `v2rayngx`
- `BRAND_GITHUB_REPO`
  Example: `MagicZ/v2rayNG`

Optional:

- `BRAND_URL_SCHEME`
  Example: `v2rayngx`

## Icons

Place replacement icons under `branding/icons/` using the same relative paths as `V2rayNG/app/src/main/`.

Examples:

- `branding/icons/ic_launcher-web.png`
- `branding/icons/res/mipmap-mdpi/ic_launcher.png`
- `branding/icons/res/mipmap-mdpi/ic_launcher_round.png`
- `branding/icons/res/mipmap-hdpi/ic_launcher.png`
- `branding/icons/res/mipmap-xhdpi/ic_banner.png`

Any file placed there will overwrite the matching app resource during the workflow build.

## Workflow Behavior

The workflow:

1. Fetches the latest `2dust/v2rayNG` `master`.
2. Skips the run if that upstream commit was already released in this repo.
3. Reapplies your branding.
4. Builds `assemblePlaystoreRelease`.
5. Publishes APKs to a GitHub Release in your fork.

It does not need to push a sync commit back to your `master` branch.
