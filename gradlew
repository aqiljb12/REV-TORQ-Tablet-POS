#!/bin/sh
# Android Studio can import this project directly. This lightweight launcher
# delegates to a locally installed Gradle when available.
if command -v gradle >/dev/null 2>&1; then exec gradle "$@"; fi
echo "Gradle is not installed in PATH. Open this project in Android Studio and let Gradle Sync download Gradle 8.9." >&2
exit 1
