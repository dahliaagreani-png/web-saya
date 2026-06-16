# Dokumentasi: Pencarian Multi-Kriteria Katalog Buku Digital

## Gambaran Umum

Sistem pencarian multi-kriteria memungkinkan pengguna (anggota dan admin) untuk mencari buku berdasarkan beberapa kriteria sekaligus:

1. **Judul Buku** (Title)
2. **Penulis/Pengarang** (Author)
3. **ISBN**
4. **Kategori** (Category)

## Fitur-Fitur

### 1. Pencarian Terpisah
Setiap kriteria pencarian memiliki field input sendiri yang dapat diisi atau dikosongkan secara independen.

**Contoh:**
- Cari judul "Laravel" tanpa kriteria lainnya
- Cari penulis "Taylor Otwell" + Kategori "Programming"
- Cari ISBN "978-0-13-468599-1"

### 2. Kombinasi Kriteria
Semua kriteria yang diisi akan digabungkan dengan operator AND (semua harus terpenuhi).

**Contoh:**
```
Judul: Laravel
Penulis: Taylor Otwell
Kategori: Programming
```
Hasil akan menampilkan buku dengan judul mengandung "Laravel" 
DAN penulis mengandung "Taylor Otwell" 
DAN kategori = Programming

### 3. Filter Aktif Display
Sistem menampilkan badge yang menunjukkan filter mana saja yang sedang aktif, dengan tombol (×) untuk menghapus filter individual.

### 4. Jumlah Hasil
Jumlah buku yang ditemukan ditampilkan di sebelah tombol Reset.

## Struktur Teknis

### File-File yang Dimodifikasi/Dibuat

#### 1. **Trait Pencarian** (`app/Traits/SearchableBook.php`)
Menyediakan query scopes untuk masing-masing kriteria:
- `filterByTitle()` - Filter berdasarkan judul
- `filterByAuthor()` - Filter berdasarkan penulis
- `filterByIsbn()` - Filter berdasarkan ISBN
- `filterByCategory()` - Filter berdasarkan kategori
- `filterByPublisher()` - Filter berdasarkan penerbit
- `filterByYear()` - Filter berdasarkan tahun publikasi
- `filterByAvailability()` - Filter ketersediaan stok
- `searchByCriteria()` - Menggabungkan semua filter

#### 2. **Model Buku** (`app/Models/Book.php`)
Menggunakan trait `SearchableBook` untuk mendapatkan akses ke semua query scopes.

```php
use App\Traits\SearchableBook;

class Book extends Model {
    use SearchableBook;
    ...
}
```

#### 3. **Controller Member** (`app/Http/Controllers/Member/CatalogController.php`)
Diperbarui untuk menangani multi-kriteria pencarian:

```php
$books = Book::with('category')
    ->searchByCriteria(
        title: $title,
        author: $author,
        isbn: $isbn,
        categoryId: $categoryId,
        onlyAvailable: true  // Hanya tampilkan buku yang tersedia
    )
    ->orderByDesc('borrow_count')
    ->paginate(12);
```

#### 4. **Controller Admin** (`app/Http/Controllers/Admin/BookController.php`)
Diperbarui dengan logika serupa (tanpa filter ketersediaan otomatis).

#### 5. **View Member** (`resources/views/member/catalog/index.blade.php`)
Form pencarian dengan 4 field terpisah + display filter aktif.

#### 6. **View Admin** (`resources/views/admin/books/index.blade.php`)
Form pencarian dengan layout responsive.

## Cara Penggunaan

### Untuk Pengguna (Member)

1. Buka halaman **Katalog Buku**
2. Di bagian **"Pencarian Multi-Kriteria"**, isi field yang ingin dicari:
   - **Judul Buku**: Ketik judul (atau bagian dari judul)
   - **Penulis/Pengarang**: Ketik nama penulis
   - **ISBN**: Ketik nomor ISBN
   - **Kategori**: Pilih dari dropdown (opsional)
3. Klik tombol **"Cari Buku"**
4. Hasil pencarian ditampilkan di bawah

**Tips:**
- Anda tidak perlu mengisi semua field, hanya field yang diperlukan
- Pencarian tidak case-sensitive (besar-kecil huruf tidak berpengaruh)
- Partial search: pencarian "Lar" akan menemukan "Laravel"
- Klik tombol **"Reset Pencarian"** untuk menghapus semua filter

### Untuk Admin

1. Buka halaman **Daftar Buku**
2. Gunakan form filter di bagian atas dengan cara yang sama seperti member
3. Hasil ditampilkan dalam format tabel

## Kompatibilitas Backward

Sistem pencarian lama (field "search" tunggal) masih didukung sebagai fallback untuk kompatibilitas dengan URL yang dibuat sebelumnya.

**Contoh URL:**
```
// Pencarian lama (masih berfungsi)
/member/catalog?search=Laravel&category_id=1

// Pencarian baru (direkomendasikan)
/member/catalog?title=Laravel&author=Taylor&category_id=1
```

## Logika Pencarian

### Untuk Member (Catalog)
```php
// Query dasar
Book::with('category')
    ->filterByTitle($title)           // WHERE title LIKE '%...%'
    ->filterByAuthor($author)         // AND author LIKE '%...%'
    ->filterByIsbn($isbn)             // AND isbn LIKE '%...%'
    ->filterByCategory($categoryId)   // AND category_id = ...
    ->filterByAvailability(true)      // AND stock > 0
    ->orderByDesc('borrow_count')     // Urut: paling banyak dipinjam
    ->paginate(12);                   // 12 per halaman
```

### Untuk Admin (Books Management)
```php
// Query dasar (sama tanpa filter ketersediaan)
Book::with('category')
    ->filterByTitle($title)
    ->filterByAuthor($author)
    ->filterByIsbn($isbn)
    ->filterByCategory($categoryId)
    ->orderBy('title')                // Urut: A-Z berdasarkan judul
    ->paginate(10);                   // 10 per halaman
```

## Performa dan Optimisasi

### Query Optimization
1. **Eager Loading**: Menggunakan `->with('category')` untuk menghindari N+1 query
2. **Pagination**: Membatasi hasil (12 per halaman member, 10 per halaman admin)
3. **Index Database**: Pastikan kolom `title`, `author`, `isbn`, `category_id` memiliki index

### Saran Index di Database
```sql
CREATE INDEX idx_book_title ON books(title);
CREATE INDEX idx_book_author ON books(author);
CREATE INDEX idx_book_isbn ON books(isbn);
CREATE INDEX idx_book_category_id ON books(category_id);
CREATE INDEX idx_book_stock ON books(stock);
```

## Pengembangan Lebih Lanjut

### Fitur yang Dapat Ditambahkan

1. **Range Filter Tahun Publikasi**
   ```blade
   <input type="number" name="year_from" placeholder="Dari tahun">
   <input type="number" name="year_to" placeholder="Hingga tahun">
   ```

2. **Filter Publisher/Penerbit**
   ```blade
   <input type="text" name="publisher" placeholder="Penerbit...">
   ```

3. **Sorting Options**
   ```blade
   <select name="sort">
       <option value="popularity">Paling Populer</option>
       <option value="newest">Terbaru</option>
       <option value="title">Judul (A-Z)</option>
   </select>
   ```

4. **Advanced Filters (Checkbox)**
   - Hanya buku yang tersedia
   - Hanya buku baru (tahun terakhir)
   - Rating tinggi

5. **Full-Text Search**
   - Implementasi Elasticsearch atau MySQL FULLTEXT SEARCH
   - Untuk hasil yang lebih relevan

### Contoh Implementasi Tambahan

```php
// Di Trait SearchableBook
public function scopeFilterByYearRange(Builder $query, ?int $yearFrom, ?int $yearTo): Builder
{
    if ($yearFrom && $yearTo) {
        return $query->whereBetween('publication_year', [$yearFrom, $yearTo]);
    }
    return $query;
}

// Di Controller
$query->searchByCriteria(
    title: $title,
    author: $author,
    isbn: $isbn,
    categoryId: $categoryId,
    year: $yearFrom ? $yearTo ? range($yearFrom, $yearTo) : null : null
);
```

## Testing

### Skenario Pengujian

1. ✅ Cari berdasarkan judul saja
2. ✅ Cari berdasarkan penulis saja
3. ✅ Cari berdasarkan ISBN saja
4. ✅ Cari berdasarkan kategori saja
5. ✅ Kombinasi: judul + penulis + kategori
6. ✅ Hasil kosong ketika tidak ada kecocokan
7. ✅ Reset filter bekerja dengan benar
8. ✅ Pagination bekerja dengan filter
9. ✅ URL query string terjaga saat paging

### Contoh Test Case

```php
// tests/Feature/SearchBookTest.php
public function test_search_books_by_title()
{
    Book::factory()->create(['title' => 'Laravel Development']);
    Book::factory()->create(['title' => 'Python Basics']);
    
    $response = $this->get('/member/catalog?title=Laravel');
    
    $response->assertStatus(200);
    $response->assertSee('Laravel Development');
    $response->assertDontSee('Python Basics');
}
```

## FAQ

**Q: Bagaimana jika saya mencari dengan kriteria yang tidak ada?**
A: Sistem akan menampilkan "Buku tidak ditemukan dalam katalog" dengan empty state message.

**Q: Apakah pencarian case-sensitive?**
A: Tidak, pencarian tidak membedakan besar-kecil huruf.

**Q: Bisakah saya mencari dengan partial text?**
A: Ya, pencarian menggunakan LIKE operator, jadi "Lar" akan menemukan "Laravel".

**Q: Bagaimana dengan buku yang stok-nya habis di member view?**
A: Untuk member, hanya buku dengan stok > 0 yang ditampilkan. Admin bisa melihat semua buku termasuk yang stok habis.

**Q: Berapa jumlah hasil maksimal per halaman?**
A: Member: 12 buku per halaman, Admin: 10 buku per halaman.

---

**Versi**: 1.0  
**Tanggal Update**: 8 Juni 2026  
**Author**: Development Team
