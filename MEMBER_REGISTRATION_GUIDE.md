# Dokumentasi: Sistem Registrasi Anggota Perpustakaan Digital dengan Kartu Anggota

## 📋 Gambaran Umum

Sistem registrasi anggota perpustakaan digital memungkinkan calon anggota untuk mendaftar secara mandiri dan secara otomatis menerima kartu anggota digital (membership card) yang dapat dicetak. Sistem ini terintegrasi dengan email notification dan barcode generation.

**Fitur Utama:**
- ✅ Registrasi mandiri (self-registration) untuk anggota baru
- ✅ Auto-generate kode anggota unik (format: AGT0001, AGT0002, etc.)
- ✅ Kartu anggota digital dengan QR code dan barcode
- ✅ Cetak kartu anggota dalam format fisik (kertas atau PVC)
- ✅ Email notifikasi selamat datang untuk anggota baru
- ✅ Dashboard khusus anggota dengan akses ke kartu anggota
- ✅ Integrasi dengan sistem peminjaman dan reservasi buku

## 🔄 Alur Registrasi

```
1. Calon Anggota
   ↓
2. Buka Halaman Registrasi (/register)
   ↓
3. Isi Form Pendaftaran (Nama, Email, Password, Phone, Address)
   ↓
4. Validasi Data + Konfirmasi Password
   ↓
5. Sistem Generate Kode Anggota (AGT####)
   ↓
6. Sistem Generate Barcode dari Kode Anggota
   ↓
7. Create User dengan Role 'member'
   ↓
8. Send Email Selamat Datang (dengan data kode anggota)
   ↓
9. Auto-login ke Member Dashboard
   ↓
10. Anggota dapat Lihat/Cetak Kartu Anggota
    ↓
11. Anggota dapat Mulai Meminjam Buku
```

## 📝 Form Registrasi

### Field yang Wajib Diisi

| Field | Tipe | Validasi | Contoh |
|-------|------|----------|--------|
| Nama Lengkap | Text | Max 255 karakter, wajib | Budi Santoso |
| Email | Email | Unique, wajib | budi@email.com |
| Password | Password | Min 6 karakter, wajib | MySecurePass123 |
| Konfirmasi Password | Password | Harus sama dengan password | MySecurePass123 |

### Field Opsional

| Field | Tipe | Validasi | Contoh |
|-------|------|----------|--------|
| No. Telepon | Text | Max 20 karakter | 081234567890 |
| Alamat | Text | Max 500 karakter | Jl. Merdeka No. 10, Bandung |

## 🎫 Kartu Anggota Digital

### Informasi yang Ditampilkan

Kartu anggota menampilkan:
- **Logo/Header**: "SIP DIGITAL" - KARTU ANGGOTA PERPUSTAKAAN
- **Nama Anggota**: Nama lengkap yang didaftar
- **Email**: Email terdaftar
- **Kode Anggota**: Format AGT0001 (unik per anggota)
- **Tanggal Terdaftar**: Saat akun dibuat
- **QR Code**: Generated dari kode anggota (untuk scan online)
- **Barcode**: SVG barcode dari kode anggota (untuk scan offline)

### Desain Kartu

- **Ukuran**: 360 x 230 pixel (standar ID card 85.6 x 53.98 mm saat dicetak)
- **Background**: Gradient gelap (navy blue to purple)
- **Warna Teks**: Putih dan abu-abu untuk kontras
- **Font**: Monospace untuk kode anggota, sans-serif untuk data lainnya

### Contoh Tampilan Kartu

```
┌─────────────────────────────────────────┐
│ SIP DIGITAL                      🏧    │
│ KARTU ANGGOTA PERPUSTAKAAN             │
│                                        │
│ Budi Santoso                           │
│ budi@email.com                         │
│ AGT0001                                │
│                                        │
│ TERDAFTAR SEJAK:      ┌──┐  ║  ║  │  │
│ 08 Juni 2026          │██│  ║██║  │██│
│                       └──┘  ║  ║  └──┘
│                        QR   Barcode    │
└─────────────────────────────────────────┘
```

## 📱 Fitur Kartu Anggota

### 1. Lihat Kartu Digital
- **URL**: `/member/member-card`
- **Fitur**: 
  - Preview kartu dalam ukuran penuh
  - Menampilkan QR Code dan Barcode
  - Panduan penggunaan kartu

### 2. Cetak Kartu
- **URL**: `/member/member-card/print` (tab baru)
- **Fitur**:
  - Halaman print-friendly
  - Optimasi untuk printer fisik
  - Gunakan `Ctrl + P` untuk membuka dialog cetak
  - Rekomendasi: Kertas tebal atau kartu PVC 250-300 gsm

### 3. Tips Mencetak

**Pengaturan Printer:**
1. Buka halaman cetak: Klik tombol "Buka File Cetak"
2. Tekan `Ctrl + P` untuk membuka dialog cetak
3. **Pengaturan Print:**
   - Paper Size: Sesuaikan dengan ukuran kartu (Custom 8.56 x 5.4 cm)
   - Margin: Minimal (minimal margin)
   - Scale: 100% (jangan auto-scale)
   - Color: Full Color
4. Klik Print

## 📧 Email Notifikasi Pendaftaran

### Konten Email

Email yang dikirim saat registrasi berhasil berisi:

1. **Header**: Logo dan sambutan selamat datang
2. **Tabel Data Anggota**: 
   - Nama, Email, Kode Anggota, Tanggal Terdaftar
   - No. Telepon dan Alamat (jika diisi)
3. **Langkah Selanjutnya**:
   - Lihat kartu anggota di dashboard
   - Cetak kartu ke kertas fisik
   - Jelajahi katalog buku
   - Mulai meminjam buku
4. **Informasi Penting**: 
   - Jangan membagikan kode anggota
5. **CTA Button**: Link ke dashboard member
6. **Footer**: Info kontak perpustakaan

### Konfigurasi Email

Email dikirim menggunakan sistem queue Laravel. Pastikan konfigurasi:

**File: `.env`**
```env
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io  # atau SMTP provider lainnya
MAIL_PORT=465
MAIL_USERNAME=your_username
MAIL_PASSWORD=your_password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@perpustakaan.local
MAIL_FROM_NAME="Perpustakaan Digital"
```

### Menjalankan Queue

```bash
# Development (tanpa background job)
# Email akan dikirim langsung saat registrasi

# Production (dengan background job)
php artisan queue:work
```

## 🔧 Struktur Teknis

### Database Fields (Users Table)

```sql
CREATE TABLE users (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'member') DEFAULT 'member',
    phone VARCHAR(20) NULLABLE,
    address TEXT NULLABLE,
    member_code VARCHAR(20) UNIQUE NULLABLE,
    barcode VARCHAR(255) NULLABLE,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

### Kode Anggota Generate

**Logika:**
1. Query user dengan `member_code` LIKE 'AGT%'
2. Cari user dengan ID tertinggi (paling baru)
3. Extract nomor dari member_code terakhir (misal: AGT0001 → 1)
4. Increment nomor (+1)
5. Pad dengan 0 menjadi 4 digit (1 → 0001)
6. Gabung dengan prefix 'AGT' → AGT0002

**Contoh:**
```
User 1: AGT0001
User 2: AGT0002
User 3: AGT0003
...
User 100: AGT0100
User 1000: AGT1000
```

### Barcode Generation

**Library**: Picqer/PHP-Barcode

**Format**: Code 128 (standard untuk library)

**Output**:
- **SVG**: Untuk preview di browser (member-card/index)
- **PNG Base64**: Untuk storing di database (registration)

**Implementasi:**
```php
use App\Services\BarcodeService;

$memberCode = 'AGT0001';
$barcodeSvg = app(BarcodeService::class)->generateSVG($memberCode);
$barcodePng = app(BarcodeService::class)->generateBase64PNG($memberCode);
```

## 📁 File-File Terkait

### Controllers

| File | Deskripsi |
|------|-----------|
| `app/Http/Controllers/AuthController.php` | Registrasi, login, logout |
| `app/Http/Controllers/Member/MemberCardController.php` | View & print kartu anggota |
| `app/Http/Controllers/Member/DashboardController.php` | Dashboard member |

### Models

| File | Deskripsi |
|------|-----------|
| `app/Models/User.php` | User model dengan relationships |

### Views

| File | Deskripsi |
|------|-----------|
| `resources/views/auth/register.blade.php` | Form registrasi |
| `resources/views/auth/login.blade.php` | Form login |
| `resources/views/member/dashboard.blade.php` | Dashboard dengan welcome banner |
| `resources/views/member/member-card/index.blade.php` | Kartu anggota preview |
| `resources/views/member/member-card/print.blade.php` | Kartu anggota untuk cetak |
| `resources/views/mail/member-registration-welcome.blade.php` | Email template |

### Mails

| File | Deskripsi |
|------|-----------|
| `app/Mail/MemberRegistrationWelcome.php` | Email notifikasi |

### Services

| File | Deskripsi |
|------|-----------|
| `app/Services/BarcodeService.php` | Generate barcode SVG & PNG |

### Routes

**File:** `routes/web.php`

```php
// Public Auth Routes
Route::middleware('guest')->group(function () {
    Route::get('/register', [AuthController::class, 'showRegister'])->name('register');
    Route::post('/register', [AuthController::class, 'register']);
    Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
    Route::post('/login', [AuthController::class, 'login']);
});

// Member Routes (authenticated)
Route::middleware('auth')->prefix('member')->group(function () {
    Route::get('/member-card', [MemberCardController::class, 'index'])->name('member.member-card.index');
    Route::get('/member-card/print', [MemberCardController::class, 'print'])->name('member.member-card.print');
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('member.dashboard');
});
```

## 🎯 Workflow Lengkap

### 1. Registrasi Anggota Baru

```
User mengakses /register
    ↓
Form Registration ditampilkan
    ↓
User mengisi:
- Nama: "Budi Santoso"
- Email: "budi@email.com"
- Password: "Password123"
- Phone: "081234567890" (optional)
- Address: "Bandung, Jawa Barat" (optional)
    ↓
User klik "Daftar Sekarang"
    ↓
Backend Validasi Data:
- Cek email unique
- Cek password min 6 char
- Cek password_confirmation match
    ↓
Generate Member Code: AGT0001
    ↓
Generate Barcode Base64 dari AGT0001
    ↓
Create User Record:
- role = 'member'
- member_code = 'AGT0001'
- barcode = 'AGT0001'
    ↓
Send Email Notification
    ↓
Auto-login ke Member Dashboard
    ↓
Dashboard menampilkan:
- Welcome Banner (karena user baru)
- Stats (0 buku dipinjam, dll)
- Quick Card Preview
    ↓
User klik "Lihat Kartu Anggota"
    ↓
Kartu ditampilkan dengan:
- Nama: "Budi Santoso"
- Email: "budi@email.com"
- Member Code: "AGT0001"
- QR Code (via API)
- Barcode (SVG)
    ↓
User klik "Buka File Cetak"
    ↓
Halaman print terbuka di tab baru
    ↓
User press Ctrl+P dan setting printer
    ↓
Kartu tercetak ke kertas/PVC
    ↓
User siap meminjam buku dengan kartu fisik
```

### 2. Admin Kelola Anggota

Admin dapat:
- Lihat daftar semua anggota
- Create anggota baru (manual)
- Edit data anggota
- Lihat detail anggota
- Delete anggota

**URL**: `/admin/members`

## 🔐 Keamanan

### Password

- Minimum 6 karakter
- Hash menggunakan bcrypt (Laravel default)
- Tidak tersimpan dalam plain text

### Member Code

- Unik per anggota
- Format: AGT + 4 digit angka (Auto-increment)
- Tidak bisa diubah manual (untuk integritas)
- Used for barcode dan qr code

### Email Verification (Optional)

Untuk enhancement di masa depan:
```php
// Bisa ditambahkan email verification
->emailVerified()
```

## 🚀 Pengembangan Lebih Lanjut

### 1. Email Verification
```php
// Kirim email verification link saat registrasi
// User harus verify email sebelum bisa menggunakan akun
Mail::to($user)->send(new VerifyEmailNotification($user));
```

### 2. Membership Expiration
```php
// Tambah field di users table:
- membership_expires_at: Tanggal expired
- membership_status: active, expired, suspended

// Logic:
- Kirim reminder email 30 hari sebelum expired
- Auto-disable akun saat expired
- Implementasi renewal process
```

### 3. Membership Tiers/Levels
```php
// Tambah field:
- membership_tier: basic, premium, platinum

// Fitur berbeda per tier:
- Basic: Limit 5 buku/month
- Premium: Limit 10 buku/month
- Platinum: Unlimited
```

### 4. SMS Notification
```php
// Kirim SMS notifikasi registrasi (untuk mobile users)
SMS::to($user->phone)->send(new RegistrationNotification($user));
```

### 5. Barcode Scanner Integration
```php
// Terima input dari barcode scanner
// Auto-process peminjaman buku dengan scan member card
// QR code untuk mobile app integration
```

## 📊 Queries Berguna

### Query Member Baru (hari ini)

```php
$newMembers = User::where('role', 'member')
    ->whereDate('created_at', today())
    ->orderByDesc('created_at')
    ->get();
```

### Query Member dengan Member Code

```php
$member = User::where('member_code', 'AGT0001')->first();
```

### Query Total Member

```php
$totalMembers = User::where('role', 'member')->count();
```

### Query Member dengan Peminjaman Aktif

```php
$membersWithActiveBorrowings = User::where('role', 'member')
    ->has('activeBorrowings')
    ->get();
```

## 🧪 Testing Checklist

- [ ] Registrasi form bisa diakses di `/register`
- [ ] Validasi form bekerja (email unique, password match, dll)
- [ ] Member code di-generate otomatis dan unique
- [ ] User auto-login setelah registrasi
- [ ] Email selamat datang terkirim
- [ ] Dashboard menampilkan welcome banner untuk user baru
- [ ] Kartu anggota bisa dilihat di `/member/member-card`
- [ ] QR code terdisplay di kartu
- [ ] Barcode terdisplay di kartu
- [ ] Halaman cetak bisa dibuka
- [ ] Kartu bisa dicetak dengan Ctrl+P
- [ ] Member bisa login setelah registrasi
- [ ] Admin bisa lihat member di `/admin/members`

## 💡 Tips Penggunaan

### Untuk Calon Anggota

1. **Registrasi**: Buka `/register` atau klik link "Daftar" di login page
2. **Isi Form**: Pastikan email valid dan password kuat
3. **Email Konfirmasi**: Cek email untuk notifikasi selamat datang
4. **Lihat Kartu**: Klik "Kartu Anggota" di dashboard
5. **Cetak Kartu**: Klik "Buka File Cetak" dan gunakan Ctrl+P
6. **Gunakan Kartu**: Bawa kartu saat meminjam buku offline

### Untuk Admin

1. **Monitor Registrasi**: Lihat member baru di `/admin/members`
2. **Validasi Data**: Pastikan data member akurat
3. **Generate Laporan**: Bisa dibuat dashboard member analytics
4. **Support**: Bantu member jika ada kendala membuka/cetak kartu

---

**Versi**: 1.0  
**Tanggal Update**: 8 Juni 2026  
**Status**: Production Ready
