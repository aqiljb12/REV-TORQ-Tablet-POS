# REV TORQ POS Android v0.6.2

Android Studio project for REV TORQ Workshop POS.

## Open
Extract this ZIP, then Android Studio -> File -> Open -> select this folder (the one containing `settings.gradle`, `build.gradle`, `app/`, and `gradle/`).

Gradle distribution: 8.9, Android Gradle Plugin: 8.7.3.

## Runtime fixes in v0.6.2
- Fixed an HTML parser-breaking `</script>` inside receipt printing JavaScript.
- Supabase SDK now uses the explicit UMD build from unpkg before the Supabase bridge.
- Supabase bridge fails clearly if SDK is unavailable instead of producing undefined `createClient` errors.
- Removed the Accounting/Monitacc runtime module from the POS web app.
- Kept existing POS/Workshop UI and production Supabase schema intact.
- Camera permission remains optional at install time and is requested only when camera access is used.

No production database reset/drop/delete is performed by this project.
