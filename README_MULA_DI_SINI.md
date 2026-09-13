# REV TORQ POS v0.8.6 — Auth fixes + Cloudflare upload

## Apa perlu dibuat sekarang

1. Extract ZIP ini di komputer. Jangan upload ZIP sebagai satu fail ke GitHub.
2. Buka folder `UPLOAD_GITHUB` di dalam hasil extract.
3. Di GitHub `aqiljb12/REV-TORQ-Tablet-POS`, pilih **Add file → Upload files**.
4. Dari File Explorer biasa, seret SEMUA kandungan dalam `UPLOAD_GITHUB` ke halaman upload GitHub. Kekalkan folder `WAB_DEPLOY` (jangan ratakan isi `js` dan `css`).
5. Di akar repo mesti kelihatan `wrangler.jsonc`, `README.md` dan folder `WAB_DEPLOY`. Jangan upload folder pembungkus `UPLOAD_GITHUB` itu sendiri.
6. Tekan **Commit changes**. Jika integrasi auto-deploy aktif, commit boleh mencetuskan deployment.
7. Dalam Cloudflare Worker **rev-torq-tablet-pos**, gunakan tetapan di bawah dan deploy semula jika perlu.

| Tetapan Cloudflare | Nilai |
| --- | --- |
| Branch | `main` |
| Root directory | `/` |
| Build command | Kosong / None |
| Deploy command | `npx wrangler@4.131.1 deploy` |
| Assets directory | Sudah ditetapkan sebagai `./WAB_DEPLOY` dalam `wrangler.jsonc` |

Jangan letak token/kata laluan dalam repo. Build token Cloudflare sedia ada dikekalkan dalam dashboard, bukan dalam fail ini. Nama Worker dalam konfigurasi mesti sepadan dengan projek Cloudflare yang dipilih.

## Kandungan pakej

- `UPLOAD_GITHUB/`: pakej website minimum, hanya fail runtime, README dan konfigurasi Cloudflare. Ini sahaja yang perlu diupload melalui browser untuk website.
- `app/`, `gradle/`, fail Gradle: sumber projek Android asal dengan pembaikan auth turut disalin ke `app/src/main/assets`. Buka akar projek ini dalam Android Studio jika mahu membina APK.
- `WAB_DEPLOY/`: salinan web penuh; `.assetsignore` mengecualikan nota dan SQL daripada hosting jika deploy dari akar projek penuh.
- `tests/`: ujian auth dengan Supabase simulasi. Jalankan `node --test tests/auth.test.cjs` dan `node tests/verify-package.cjs` dari akar projek.
- Nota versi lama dan SQL asal dikekalkan sebagai sejarah. Jangan jalankan SQL lama semata-mata untuk menggunakan versi ini.

## Perubahan keselamatan

- Buang kata laluan override yang ditulis terus dalam JavaScript.
- Flag `rt_override_mode` dan teks peranan pada DOM tidak lagi memberikan akses admin.
- Satu aliran login/restore/logout. Kod login legacy tidak lagi menjadi fallback.
- Semak pengguna melalui `auth.getUser()`, kemudian tepat satu staff aktif berdasarkan `auth_user_id`. Staff ID yang ditaip juga mesti sepadan.
- Tolak profil tiada company, staff dibuang, role kosong/tidak dikenal atau pemadanan berganda. Alias administrator/superadmin dipetakan kepada role sedia ada.
- Cache profil tempatan bukan sumber autoriti. Konteks staff/company/location disahkan semula melalui identiti Auth.
- Logout setempat membersihkan cache, override, state aplikasi dan token projek tanpa memadam tetapan/device ID. Jika pembatalan pelayan gagal, aplikasi memberitahu pengguna; sesi tempatan tetap dikunci.
- PIN dikosongkan selepas percubaan login. UI PIN enam digit dikekalkan.
- Setup Initial Admin dari browser dinyahaktifkan dalam pakej production ini. Akaun owner sedia ada tidak diubah.
- Menu admin tidak lagi menjadi default bagi role tidak dikenali.
- Fail CSS, susunan HTML, navigasi dan kod pembayaran tidak direka semula.

## Batas pengesahan — PENTING

Ini pembaikan frontend, BUKAN pengesahan bahawa database production selamat.
Tiada perubahan database, GitHub atau deployment dilakukan oleh pembinaan pakej ini.
Tiada service-role key ditemui dalam konfigurasi runtime yang disemak; publishable key asal dikekalkan.

RLS/RPC production, bootstrap owner di pelayan, rate limit PIN dan tempoh token masih perlu disemak. Menutup butang bootstrap tidak membatalkan akses RPC di pelayan.
Pengguna boleh mengubah kod browser: setiap tindakan sensitif mesti disahkan semula oleh RLS/RPC menggunakan identiti token sebenar.
Staff lama tanpa pemadanan `auth_user_id` yang betul akan ditolak dengan sengaja. Jangan tambah semula fallback atau matikan RLS; betulkan pemadanan melalui admin yang sah.

Ujian automatik menggunakan data simulasi sahaja. Login akaun sebenar, build APK, transaksi, printer, scanner dan deployment Cloudflare sebenar belum disahkan.
Selepas deploy, uji satu akaun owner dan satu akaun staff dahulu. Pastikan staff tidak mendapat menu admin, logout/login tidak mewarisi akses, kemudian uji operasi POS biasa.
Tiada APK siap bina disertakan.

## Rujukan teknikal

- https://supabase.com/docs/reference/javascript/auth-getuser
- https://supabase.com/docs/reference/javascript/auth-signout
- https://developers.cloudflare.com/workers/static-assets/get-started/
