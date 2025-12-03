-- ============================================
-- BENCHMARK QUERIES: 1NF VS 3NF
-- ============================================
-- Tujuan:
--   Membandingkan performa query antara struktur 1NF (denormalized)
--   dengan 3NF (normalized) menggunakan kasus-kasus realistis.
--
-- Cara Pengujian:
--   1. Jalankan query dengan SQL_NO_CACHE untuk hasil akurat
--   2. Catat waktu eksekusi (Duration) dari MySQL Workbench/CLI
--   3. Ulangi 3-5 kali, ambil rata-rata
--   4. Bandingkan hasilnya
--
-- Cara Membaca Hasil:
--   - Duration < 0.1 detik  : Sangat Cepat
--   - Duration 0.1-0.5 detik: Cepat
--   - Duration 0.5-2 detik  : Normal
--   - Duration > 2 detik    : Lambat (perlu optimasi)
-- ============================================

-- ============================================
-- PERSIAPAN: CLEAR QUERY CACHE
-- ============================================
-- Jalankan sebelum setiap test untuk hasil yang fair
RESET QUERY CACHE;

-- ============================================
-- KASUS A: SIMPLE SELECT
-- Query: Cari semua mata kuliah yang diambil oleh mahasiswa tertentu
-- ============================================

-- --------------------
-- QUERY 1NF (Flat Table)
-- --------------------
-- Catatan: Cepat karena tidak perlu JOIN, semua data dalam 1 tabel
SELECT SQL_NO_CACHE 
    nama_mhs,
    nim,
    kode_mk,
    nama_mk,
    sks,
    nama_dosen
FROM tabel_krs_1nf
WHERE nama_mhs LIKE '%Budi%'
ORDER BY kode_mk;

-- Ekspektasi: SANGAT CEPAT (< 0.05 detik)
-- Mengapa? Index pada nama_mhs + tidak ada JOIN

-- --------------------
-- QUERY 3NF (Normalized)
-- --------------------
-- Catatan: Perlu JOIN 3 tabel, tapi data lebih terstruktur
SELECT SQL_NO_CACHE 
    m.nama_lengkap,
    m.nim,
    mk.kode_mk,
    mk.nama_mk,
    mk.sks,
    d.nama_lengkap AS nama_dosen
FROM mahasiswa m
INNER JOIN krs k ON m.nim = k.nim
INNER JOIN mata_kuliah mk ON k.kode_mk = mk.kode_mk
INNER JOIN dosen d ON mk.nidn_dosen = d.nidn
WHERE m.nama_lengkap LIKE '%Budi%'
ORDER BY mk.kode_mk;

-- Ekspektasi: CEPAT (0.05-0.15 detik)
-- Mengapa? Perlu JOIN 4 tabel, tapi dengan index yang tepat tetap efisien


-- ============================================
-- KASUS B: COMPLEX AGGREGATION
-- Query: Hitung total SKS yang diajar oleh setiap dosen
--        (termasuk nama dosen dan jumlah mahasiswa yang mengambil)
-- ============================================

-- --------------------
-- QUERY 1NF (Flat Table)
-- --------------------
-- Catatan: Mudah karena semua kolom sudah ada, tapi harus DISTINCT
SELECT SQL_NO_CACHE 
    nidn_dosen,
    nama_dosen,
    SUM(sks) AS total_sks_diajar,
    COUNT(DISTINCT nim) AS jumlah_mahasiswa
FROM tabel_krs_1nf
GROUP BY nidn_dosen, nama_dosen
ORDER BY total_sks_diajar DESC
LIMIT 20;

-- Ekspektasi: CEPAT (0.1-0.3 detik)
-- Mengapa? Agregasi sederhana tanpa JOIN, tapi harus scan banyak row


-- --------------------
-- QUERY 3NF (Normalized)
-- --------------------
-- Catatan: Perlu JOIN untuk menggabungkan data dari berbagai tabel
SELECT SQL_NO_CACHE 
    d.nidn,
    d.nama_lengkap AS nama_dosen,
    SUM(mk.sks) AS total_sks_diajar,
    COUNT(DISTINCT k.nim) AS jumlah_mahasiswa
FROM dosen d
INNER JOIN mata_kuliah mk ON d.nidn = mk.nidn_dosen
INNER JOIN krs k ON mk.kode_mk = k.kode_mk
GROUP BY d.nidn, d.nama_lengkap
ORDER BY total_sks_diajar DESC
LIMIT 20;

-- Ekspektasi: NORMAL (0.2-0.5 detik)
-- Mengapa? JOIN + GROUP BY pada dataset besar, tapi masih efisien dengan index


-- ============================================
-- KASUS C: DATA UPDATE (UPDATE ANOMALY TEST)
-- Query: Dosen "Dr. Siti" ganti nomor HP menjadi "081234567890"
-- ============================================

-- LANGKAH 1: Cari dosen yang bernama "Siti" (untuk dapat nidn/nidn_dosen)
-- Query ini hanya untuk mencari NIDN, jalankan dulu sebelum UPDATE

-- Untuk 1NF:
SELECT DISTINCT nidn_dosen, nama_dosen 
FROM tabel_krs_1nf 
WHERE nama_dosen LIKE '%Siti%' 
LIMIT 1;

-- Untuk 3NF:
SELECT nidn, nama_lengkap 
FROM dosen 
WHERE nama_lengkap LIKE '%Siti%' 
LIMIT 1;

-- Asumsikan hasilnya: nidn = '0123456789'

-- --------------------
-- UPDATE 1NF (Flat Table)
-- --------------------
-- MASALAH: Harus update RIBUAN ROW karena data dosen terduplikasi!
UPDATE tabel_krs_1nf
SET nohp_dosen = '081234567890'
WHERE nidn_dosen = '0123456789';

-- Ekspektasi: LAMBAT (0.5-2 detik)
-- Mengapa? Update banyak row sekaligus (bisa ratusan/ribuan row)
-- RISIKO: Jika gagal di tengah jalan, bisa terjadi DATA INCONSISTENCY!

-- Cek berapa row yang ter-update:
-- SELECT ROW_COUNT();


-- --------------------
-- UPDATE 3NF (Normalized)
-- --------------------
-- SOLUSI: Update hanya 1 ROW di tabel master!
UPDATE dosen
SET no_hp = '081234567890'
WHERE nidn = '0123456789';

-- Ekspektasi: SANGAT CEPAT (< 0.01 detik)
-- Mengapa? Hanya update 1 row di tabel master
-- KEUNTUNGAN: Perubahan langsung berlaku untuk semua relasi (via FK)

-- Cek berapa row yang ter-update:
-- SELECT ROW_COUNT();  -- Hasilnya: 1


-- ============================================
-- BONUS: QUERY UNTUK CEK UKURAN TABEL (STORAGE)
-- ============================================
-- Bandingkan ukuran storage antara 1NF dan 3NF

SELECT 
    table_name AS 'Nama Tabel',
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Ukuran (MB)',
    table_rows AS 'Jumlah Baris'
FROM information_schema.TABLES
WHERE table_schema = DATABASE()
    AND table_name IN ('tabel_krs_1nf', 'mahasiswa', 'dosen', 'mata_kuliah', 'krs')
ORDER BY (data_length + index_length) DESC;

-- Ekspektasi:
-- - tabel_krs_1nf: ~5-10 MB (BESAR karena banyak duplikasi)
-- - Total 3NF (4 tabel): ~2-4 MB (LEBIH KECIL karena normalisasi)


-- ============================================
-- TIPS UNTUK BENCHMARKING YANG AKURAT
-- ============================================
-- 1. Restart MySQL service sebelum testing
-- 2. Jalankan setiap query 3-5 kali, ambil rata-rata
-- 3. Gunakan EXPLAIN untuk analisis query plan
-- 4. Perhatikan "Rows Examined" di EXPLAIN output
-- 5. Pastikan index sudah dibuat dengan benar
--
-- Contoh EXPLAIN:
-- EXPLAIN SELECT SQL_NO_CACHE ...
--
-- Kolom penting:
-- - type: ALL (buruk), index (bagus), ref (bagus), const (sangat bagus)
-- - rows: Jumlah baris yang diperiksa (semakin kecil semakin baik)
-- - Extra: Using index (bagus), Using filesort (buruk untuk data besar)
-- ============================================


-- ============================================
-- TEMPLATE UNTUK DOKUMENTASI HASIL
-- ============================================
/*
HASIL BENCHMARK (Contoh):

+------------------+------------------+------------------+
| Kasus            | 1NF (detik)      | 3NF (detik)      |
+------------------+------------------+------------------+
| Simple SELECT    | 0.03             | 0.12             |
| Complex Agg      | 0.18             | 0.35             |
| UPDATE 1 Dosen   | 1.25             | 0.01             |
+------------------+------------------+------------------+

UKURAN STORAGE:
- 1NF: 8.5 MB
- 3NF (Total): 3.2 MB

KESIMPULAN:
- 1NF menang untuk SIMPLE SELECT (3-4x lebih cepat)
- 3NF menang untuk UPDATE (100x lebih cepat!)
- 3NF lebih hemat storage (60% lebih kecil)
*/
