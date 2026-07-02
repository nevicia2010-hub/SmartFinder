#!/usr/bin/env bash
set -euo pipefail

APP_PATH="${1:-.build/package/SmartFinder.app}"
INFO_PLIST="${APP_PATH}/Contents/Info.plist"
ICON_FILE="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIconFile' "${INFO_PLIST}" 2>/dev/null || true)"

if [[ -z "${ICON_FILE}" ]]; then
    echo "FAIL: CFBundleIconFile is missing from ${INFO_PLIST}" >&2
    exit 1
fi

if [[ "${ICON_FILE}" != *.icns ]]; then
    ICON_FILE="${ICON_FILE}.icns"
fi

ICON_PATH="${APP_PATH}/Contents/Resources/${ICON_FILE}"
if [[ ! -s "${ICON_PATH}" ]]; then
    echo "FAIL: icon file is missing or empty: ${ICON_PATH}" >&2
    exit 1
fi

codesign --verify --deep --strict "${APP_PATH}"
echo "Package check passed: ${APP_PATH}"
