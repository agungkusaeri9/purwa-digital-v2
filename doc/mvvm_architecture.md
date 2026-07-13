# MVVM Feature-First

`core` memuat infrastruktur lintas aplikasi: network, storage, errors, utils, extensions, constants, themes, router, dan services. `config` menangani environment serta dependency injection. `shared` hanya untuk UI/validasi yang dipakai minimal dua feature. `features` adalah pemilik seluruh use case dan UI bisnis.

Setiap feature menggunakan `models`, `viewmodels`, `views`, `services`, `repositories`, `widgets`, `providers`, `enums`, dan `constants`. Jangan buat folder kosong menjadi kewajiban: tambahkan file hanya saat tanggung jawabnya ada.

Alur login: `LoginPage` membaca state dan meneruskan intent → `LoginViewModel.submit` → `AuthRepository.login` → `AuthService.login` → `ApiClient/Dio` → `AuthToken`; repository menyimpan token melalui `SecureStorageService`; ViewModel menerbitkan state baru untuk UI.

Aturan impor: gunakan `dart:` lalu `package:` lalu relative import, tiap kelompok dipisahkan satu baris. Relative import dipakai di dalam feature yang sama; gunakan package import untuk lintas feature atau core agar relokasi file aman. Hindari file barrel besar dan impor `views` dari ViewModel.

Konvensi: semua berkas `snake_case.dart`; tipe `PascalCase`; variabel/metode `camelCase`; provider berakhiran `Provider`; ViewModel berakhiran `ViewModel`; halaman berakhiran `Page`; widget kecil berakhiran deskriptif seperti `LoginForm`; request/response bernama `LoginRequest` dan `AuthToken`.

Riverpod: ViewModel memiliki satu state immutable, View hanya `watch` state dan `read(...notifier)` untuk aksi; side effect navigasi/snackbar dipasang lewat `ref.listen`; provider service/repository berada di `providers`; jangan menyimpan `BuildContext` di ViewModel.

Freezed: model immutable memakai `@freezed`, constructor `const factory`, dan `fromJson`; setelah mengubah model jalankan `dart run build_runner build --delete-conflicting-outputs`. Kode `*.freezed.dart` dan `*.g.dart` adalah hasil generator dan disimpan di Git.
