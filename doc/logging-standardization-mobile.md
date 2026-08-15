# Mobile Logging Standardization (Standar Logging Aplikasi Mobile)

## 1. Purpose (Tujuan)

Dokumen ini mendefinisikan standar logging yang digunakan pada aplikasi Flutter Mobile (`purwa-digital-mobile`) agar:

- **Terstruktur & Konsisten**: Pencatatan log terpusat menggunakan `AppLogger` dan paket `logger`.
- **Informatif**: Memudahkan debugging HTTP Network Request, Dio Interceptor, State Management (Riverpod), dan Exception.
- **Aman (Sanitasi Data)**: Otomatis melakukan sanitasi (*masking*) data sensitif (PIN, Password, Token Auth, Secret).
- **Berkinerja Baik**: Hanya menampilkan detail log tingkat tinggi (*Pretty Printer*) di mode Debug (`kDebugMode`) dan mengurangi noise di mode Production.

---

## 2. Architecure & Technology

- **Framework**: Package `logger` (v2.5.0) via wrapper [AppLogger](file:///e:/apps/purwa-digital/purwa-digital-mobile/lib/core/services/app_logger.dart).
- **Network Tracing**: Interceptor [DioLoggingInterceptor](file:///e:/apps/purwa-digital/purwa-digital-mobile/lib/core/network/dio_logging_interceptor.dart) dipasang pada instance Dio di `ApiClient`.
- **Pretty Printer**: Menampilkan timestamp, nama kelas, icon/emoji status, dan durasi latensi request.

---

## 3. Log Levels & Penggunaan

| Level | Method | Penggunaan | Contoh |
|---|---|---|---|
| `Debug` | `AppLogger.debug()` | Detail eksekusi teknis untuk debugging lokal. | Dynamic payload parsing, state change trace. |
| `Info` | `AppLogger.info()` | Alur kerja normal aplikasi. | HTTP Request/Response, navigasi halaman, transaksi dibuat. |
| `Warn` | `AppLogger.warn()` | Kondisi abnormal yang masih dapat ditangani. | Retry koneksi, form validation warning, token refresh. |
| `Error` | `AppLogger.error()` | Error/Exception pada HTTP atau runtime app. | Network exception, 400 Bad Request, API failure, crash report. |

---

## 4. Keamanan & Masking Data Sensitif

Log **TIDAK BOLEH** menampilkan data sensitif dalam plain text di konsol.

Pembersihan data dilakukan otomatis oleh `AppLogger.sanitizeData()` untuk key berikut:
- `pin`
- `password` / `confirm_password`
- `token` / `access_token` / `refresh_token`
- Header `Authorization`

### Contoh Output Log Request:
```text
🌐 HTTP REQUEST [POST] https://api.purwa-digital.purwatechsolutions.com/api/digiflazz/transaction
Headers: {Content-Type: application/json, Authorization: Bearer [REDACTED]}
Body: {buyer_sku_code: post645440, customer_no: 530000000001, pin: [REDACTED]}
```

---

## 5. Network Logging (Dio Interceptor)

Setiap request HTTP melalui `ApiClient` otomatis dicatat:
- **Request**: URL lengkap, query parameters, header (dengan `Authorization` di-mask), dan body (dengan `pin`/`password` di-mask).
- **Response**: Status Code, latensi dalam milidetik (`ms`), dan payload respon JSON.
- **Error**: Status Code error, durasi, detail pesan error, dan StackTrace jika ada.

---

## 6. Best Practices

1. Selalu gunakan `AppLogger.info()`, `AppLogger.error()`, atau `AppLogger.debug()` daripada menggunakan `print()` atau `debugPrint()` bawaan Dart.
2. Saat menangkap exception pada View / ViewModel, catat ke `AppLogger.error()` dengan menyertakan objek `error` dan `stackTrace`.
