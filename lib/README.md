# Bilingual PDF App (Flutter)

## Features
- ✅ Registration & Login (connects to Laravel API)
- ✅ English / Arabic language toggle (full RTL support)
- ✅ Polished UI with gradient headers and Material 3 design
- ✅ Dashboard with PDF viewer (different PDFs per language)
- ✅ Session persistence via file-based storage (no plugin required)
- ✅ Logout confirmation dialog
- ✅ Page counter in PDF viewer
- ✅ Proper error messages in both languages

## Project Structure
```
lib/
├── main.dart                    # App entry, providers, theme, splash
├── models/
│   └── user_model.dart          # User data class
├── services/
│   └── api_service.dart         # All API calls (Dio)
├── providers/
│   ├── auth_provider.dart       # Login/register/logout + secure storage
│   └── language_provider.dart   # EN/AR locale switching
├── screens/
│   ├── login_screen.dart        # Login with gradient header + lang toggle
│   ├── register_screen.dart     # Register with confirm password + lang toggle
│   └── dashboard_screen.dart    # PDF viewer + user banner + language toggle
└── l10n/
    ├── app_en.arb               # English strings
    └── app_ar.arb               # Arabic strings
```

## Setup

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Configure your API base URL

Edit `lib/services/api_service.dart`:
```dart
// Android Emulator (maps to PC localhost)
static const String _baseUrl = 'http://10.0.2.2:8000/api';

// Real device (use your PC's LAN IP)
static const String _baseUrl = 'http://192.168.1.100:8000/api';

// Production
static const String _baseUrl = 'https://yourdomain.com/api';
```

### 3. Add PDF API endpoint to Laravel backend

```
GET /api/pdf?lang=en   → returns English PDF (application/pdf)
GET /api/pdf?lang=ar   → returns Arabic PDF (application/pdf)
```

Example Laravel route:
```php
Route::get('/pdf', function (Request $request) {
    $lang = $request->query('lang', 'en');
    $path = storage_path("app/pdfs/document_{$lang}.pdf");
    return response()->file($path, ['Content-Type' => 'application/pdf']);
});
```

### 4. Run
```bash
flutter run
```

## API Response format (signup/signin)
```json
{
  "id": 6,
  "first_name": "shahin",
  "last_name": "test",
  "email": "user@example.com",
  "role": "0"
}
```

## Notes
- `android:usesCleartextTraffic="true"` is set in AndroidManifest for dev HTTP.
  **Remove this for production and use HTTPS.**
- The app uses `10.0.2.2` as the default API host — correct for Android Emulator.
  Change to your LAN IP for real device testing.
