-- ============================================
-- TESTING PERFORMA: 1NF VS 3NF
-- ============================================
-- Tujuan:
--   Membuktikan perbedaan kecepatan query antara:
--   - 1NF (Denormalized): Tabel Flat dengan duplikasi data
--   - 3NF (Normalized): Tabel terpisah dengan JOIN
--
-- Cara Penggunaan:
--   1. Pastikan data sudah di-import (1NF & 3NF)
--   2. Jalankan query satu per satu di MySQL Workbench
--   3. Catat "Duration" di bagian bawah untuk setiap query
--   4. Ulangi 3-5 kali, ambil rata-rata
--   5. Bandingkan hasilnya
--
-- Metrics yang Diukur:
--   - Execution Time (Duration)
--   - Rows Examined
--   - Rows Affected (untuk UPDATE/DELETE)
-- ============================================

USE experiment_db;

-- ============================================
-- PERSIAPAN: RESET QUERY CACHE
-- ============================================
-- Jalankan ini sebelum SETIAP test untuk hasil yang fair
RESET QUERY CACHE;
SET profiling = 1;

-- ============================================
-- TEST 1: SIMPLE SELECT (Cari KRS 1 Mahasiswa)
-- ============================================
-- Skenario: Tampilkan semua mata kuliah yang diambil mahasiswa dengan NIM tertentu
-- Expected: 1NF lebih cepat (tidak perlu JOIN)

-- 📊 TEST 1A: 1NF (FLAT TABLE)
SELECT SQL_NO_CACHE 
    nim,
    nama_mhs,
    kode_mk,
    nama_mk,
    sks,
    nama_dosen,
    nohp_mhs
FROM tabel_krs_1nf
WHERE nim = '202000001'
ORDER BY kode_mk;

-- ⏱️ CATAT DURATION: __________ detik

-- 📊 TEST 1B: 3NF (NORMALIZED dengan JOIN)
SELECT SQL_NO_CACHE 
    m.nim,
    m.nama_lengkap AS nama_mhs,
    mk.kode_mk,
    mk.nama_mk,
    mk.sks,
    d.nama_lengkap AS nama_dosen,
    m.nohp_mhs
FROM mahasiswa m
INNER JOIN krs k ON m.nim = k.nim
INNER JOIN mata_kuliah mk ON k.kode_mk = mk.kode_mk
INNER JOIN dosen d ON mk.nidn_dosen = d.nidn
WHERE m.nim = '202000001'
ORDER BY mk.kode_mk;

-- ⏱️ CATAT DURATION: __________ detik

-- ============================================
-- TEST 2: SEARCH dengan LIKE (Cari Mahasiswa bernama "Siti")
-- ============================================
-- Skenario: Cari semua KRS mahasiswa yang namanya mengandung "Siti"
-- Expected: 1NF lebih cepat (akses langsung tanpa JOIN)

-- 📊 TEST 2A: 1NF
SELECT SQL_NO_CACHE 
    nim,
    nama_mhs,
    kode_mk,
    nama_mk,
    sks,
    nama_dosen
FROM tabel_krs_1nf
WHERE nama_mhs LIKE '%Siti%'
ORDER BY nim, kode_mk;

-- ⏱️ CATAT DURATION: __________ detik
-- ⏱️ CATAT ROWS RETURNED: __________ rows

-- 📊 TEST 2B: 3NF
SELECT SQL_NO_CACHE 
    m.nim,
    m.nama_lengkap AS nama_mhs,
    mk.kode_mk,
    mk.nama_mk,
    mk.sks,
    d.nama_lengkap AS nama_dosen
FROM mahasiswa m
INNER JOIN krs k ON m.nim = k.nim
INNER JOIN mata_kuliah mk ON k.kode_mk = mk.kode_mk
INNER JOIN dosen d ON mk.nidn_dosen = d.nidn
WHERE m.nama_lengkap LIKE '%Siti%'
ORDER BY m.nim, mk.kode_mk;

-- ⏱️ CATAT DURATION: __________ detik
-- ⏱️ CATAT ROWS RETURNED: __________ rows

-- ============================================
-- TEST 3: AGGREGATION (Hitung Total SKS per Dosen)
-- ============================================
-- Skenario: Hitung total SKS yang diajar setiap dosen dan jumlah mahasiswa
-- Expected: 1NF lebih cepat (data sudah flat, tinggal GROUP BY)

-- 📊 TEST 3A: 1NF
SELECT SQL_NO_CACHE 
    nidn_dosen,
    nama_dosen,
    SUM(DISTINCT sks) AS total_sks_diajar,
    COUNT(DISTINCT nim) AS jumlah_mahasiswa
FROM tabel_krs_1nf
GROUP BY nidn_dosen, nama_dosen
ORDER BY total_sks_diajar DESC, jumlah_mahasiswa DESC
LIMIT 20;

-- ⏱️ CATAT DURATION: __________ detik

-- 📊 TEST 3B: 3NF
SELECT SQL_NO_CACHE 
    d.nidn,
    d.nama_lengkap AS nama_dosen,
    SUM(DISTINCT mk.sks) AS total_sks_diajar,
    COUNT(DISTINCT k.nim) AS jumlah_mahasiswa
FROM dosen d
INNER JOIN mata_kuliah mk ON d.nidn = mk.nidn_dosen
INNER JOIN krs k ON mk.kode_mk = k.kode_mk
GROUP BY d.nidn, d.nama_lengkap
ORDER BY total_sks_diajar DESC, jumlah_mahasiswa DESC
LIMIT 20;

-- ⏱️ CATAT DURATION: __________ detik

-- ============================================
-- TEST 4: COMPLEX JOIN (Mata Kuliah Populer)
-- ============================================
-- Skenario: Cari 10 mata kuliah paling banyak diambil mahasiswa
-- Expected: 1NF lebih cepat

-- 📊 TEST 4A: 1NF
SELECT SQL_NO_CACHE 
    kode_mk,
    nama_mk,
    nama_dosen,
    sks,
    COUNT(DISTINCT nim) AS jumlah_mahasiswa
FROM tabel_krs_1nf
GROUP BY kode_mk, nama_mk, nama_dosen, sks
ORDER BY jumlah_mahasiswa DESC
LIMIT 10;

-- ⏱️ CATAT DURATION: __________ detik

-- 📊 TEST 4B: 3NF
SELECT SQL_NO_CACHE 
    mk.kode_mk,
    mk.nama_mk,
    d.nama_lengkap AS nama_dosen,
    mk.sks,
    COUNT(DISTINCT k.nim) AS jumlah_mahasiswa
FROM mata_kuliah mk
INNER JOIN krs k ON mk.kode_mk = k.kode_mk
INNER JOIN dosen d ON mk.nidn_dosen = d.nidn
GROUP BY mk.kode_mk, mk.nama_mk, d.nama_lengkap, mk.sks
ORDER BY jumlah_mahasiswa DESC
LIMIT 10;

-- ⏱️ CATAT DURATION: __________ detik

-- ============================================
-- TEST 5: COUNT ROWS (Hitung Total Data)
-- ============================================
-- Skenario: Hitung total transaksi KRS
-- Expected: 1NF lebih cepat (1 tabel vs 1 tabel)

-- 📊 TEST 5A: 1NF
SELECT SQL_NO_CACHE COUNT(*) AS total_krs
FROM tabel_krs_1nf;

-- ⏱️ CATAT DURATION: __________ detik

-- 📊 TEST 5B: 3NF
SELECT SQL_NO_CACHE COUNT(*) AS total_krs
FROM krs;

-- ⏱️ CATAT DURATION: __________ detik

-- ============================================
-- TEST 6: UPDATE (Update Anomaly Test)
-- ============================================
-- Skenario: Update nomor HP mahasiswa
-- Expected: 3NF JAUH LEBIH CEPAT (update 1 row vs ribuan row)

-- 📊 TEST 6A: 1NF (UPDATE BANYAK ROW - BAHAYA!)
-- Step 1: Cek berapa row yang akan di-update
SELECT COUNT(*) AS jumlah_row_akan_diupdate
FROM tabel_krs_1nf
WHERE nim = '202000001';

-- ⏱️ CATAT JUMLAH ROW: __________ rows

-- Step 2: Backup dulu (PENTING!)
CREATE TEMPORARY TABLE backup_1nf AS
SELECT * FROM tabel_krs_1nf WHERE nim = '202000001';

-- Step 3: UPDATE
UPDATE tabel_krs_1nf
SET nohp_mhs = '0811-9999-9999'
WHERE nim = '202000001';

-- ⏱️ CATAT DURATION: __________ detik
-- ⏱️ CATAT ROWS AFFECTED: __________ rows

-- Step 4: Restore (kembalikan seperti semula)
UPDATE tabel_krs_1nf t
INNER JOIN backup_1nf b ON t.nim = b.nim AND t.kode_mk = b.kode_mk
SET t.nohp_mhs = b.nohp_mhs;

DROP TEMPORARY TABLE backup_1nf;

-- 📊 TEST 6B: 3NF (UPDATE 1 ROW - AMAN!)
-- Step 1: Cek data sekarang
SELECT nim, nama_lengkap, nohp_mhs
FROM mahasiswa
WHERE nim = '202000001';

-- Step 2: UPDATE (hanya 1 row!)
UPDATE mahasiswa
SET nohp_mhs = '0811-9999-9999'
WHERE nim = '202000001';

-- ⏱️ CATAT DURATION: __________ detik
-- ⏱️ CATAT ROWS AFFECTED: 1 row (selalu!)

-- Step 3: Restore
UPDATE mahasiswa
SET nohp_mhs = (
    SELECT nohp_mhs FROM (
        SELECT nohp_mhs FROM mahasiswa WHERE nim = '202000001'
    ) AS temp
)
WHERE nim = '202000001';

-- ============================================
-- TEST 7: DELETE (Hapus Data Mahasiswa)
-- ============================================
-- Skenario: Hapus 1 mahasiswa beserta semua KRS-nya
-- Expected: 3NF lebih aman (CASCADE otomatis)

-- 📊 TEST 7A: 1NF (Harus manual hapus semua row KRS)
-- Step 1: Cek berapa row yang akan dihapus
SELECT COUNT(*) AS jumlah_row_akan_dihapus
FROM tabel_krs_1nf
WHERE nim = '202000999';

-- ⏱️ CATAT JUMLAH ROW: __________ rows

-- Step 2: Backup
CREATE TEMPORARY TABLE backup_delete_1nf AS
SELECT * FROM tabel_krs_1nf WHERE nim = '202000999';

-- Step 3: DELETE
DELETE FROM tabel_krs_1nf
WHERE nim = '202000999';

-- ⏱️ CATAT DURATION: __________ detik
-- ⏱️ CATAT ROWS AFFECTED: __________ rows

-- Step 4: Restore
INSERT INTO tabel_krs_1nf SELECT * FROM backup_delete_1nf;
DROP TEMPORARY TABLE backup_delete_1nf;

-- 📊 TEST 7B: 3NF (CASCADE otomatis!)
-- Step 1: Cek data mahasiswa dan KRS-nya
SELECT m.nim, m.nama_lengkap, COUNT(k.kode_mk) AS jumlah_mk
FROM mahasiswa m
LEFT JOIN krs k ON m.nim = k.nim
WHERE m.nim = '202000999'
GROUP BY m.nim, m.nama_lengkap;

-- Step 2: Backup
CREATE TEMPORARY TABLE backup_mhs AS
SELECT * FROM mahasiswa WHERE nim = '202000999';

CREATE TEMPORARY TABLE backup_krs AS
SELECT * FROM krs WHERE nim = '202000999';

-- Step 3: DELETE (otomatis hapus di tabel krs juga karena CASCADE!)
DELETE FROM mahasiswa
WHERE nim = '202000999';

-- ⏱️ CATAT DURATION: __________ detik
-- ⏱️ CATAT ROWS AFFECTED (mahasiswa): 1 row
-- ⏱️ CATAT ROWS AFFECTED (krs): auto-deleted!

-- Step 4: Restore
INSERT INTO mahasiswa SELECT * FROM backup_mhs;
INSERT INTO krs SELECT nim, kode_mk FROM backup_krs;

DROP TEMPORARY TABLE backup_mhs;
DROP TEMPORARY TABLE backup_krs;

-- ============================================
-- TEST 8: FULL TABLE SCAN
-- ============================================
-- Skenario: Query tanpa WHERE (scan semua data)
-- Expected: 1NF lebih cepat (1 tabel vs JOIN 4 tabel)

-- 📊 TEST 8A: 1NF
SELECT SQL_NO_CACHE COUNT(*) 
FROM tabel_krs_1nf;

-- ⏱️ CATAT DURATION: __________ detik

-- 📊 TEST 8B: 3NF
SELECT SQL_NO_CACHE COUNT(*) 
FROM mahasiswa m
INNER JOIN krs k ON m.nim = k.nim
INNER JOIN mata_kuliah mk ON k.kode_mk = mk.kode_mk
INNER JOIN dosen d ON mk.nidn_dosen = d.nidn;

-- ⏱️ CATAT DURATION: __________ detik

-- ============================================
-- TEST 9: CHECK STORAGE SIZE (Ukuran Database)
-- ============================================
-- Skenario: Bandingkan ukuran storage yang digunakan
-- Expected: 3NF lebih hemat (60-70% lebih kecil)

SELECT 
    table_name AS 'Nama Tabel',
    ROUND((data_length + index_length) / 1024 / 1024, 2) AS 'Ukuran (MB)',
    table_rows AS 'Jumlah Baris',
    ROUND((data_length + index_length) / table_rows, 2) AS 'Bytes per Row'
FROM information_schema.TABLES
WHERE table_schema = 'experiment_db'
    AND table_name IN ('tabel_krs_1nf', 'mahasiswa', 'dosen', 'mata_kuliah', 'krs')
ORDER BY (data_length + index_length) DESC;

-- ⏱️ CATAT UKURAN:
-- tabel_krs_1nf: __________ MB
-- Total 3NF (mhs + dosen + mk + krs): __________ MB

-- ============================================
-- TEST 10: PROFILING (Detail Analisis)
-- ============================================
-- Gunakan ini untuk melihat detail breakdown waktu eksekusi

-- Lihat profiling untuk query terakhir
SHOW PROFILES;

-- Lihat detail untuk query tertentu (ganti X dengan Query_ID)
-- SHOW PROFILE FOR QUERY X;

-- ============================================
-- SUMMARY TESTING
-- ============================================
-- Buat tabel ringkasan hasil testing:
/*
+---------------------------+----------------+----------------+------------+
| Test Case                 | 1NF (detik)    | 3NF (detik)    | Pemenang   |
+---------------------------+----------------+----------------+------------+
| Simple SELECT             | [isi]          | [isi]          | [analisis] |
| LIKE Search               | [isi]          | [isi]          | [analisis] |
| Aggregation               | [isi]          | [isi]          | [analisis] |
| Complex Join              | [isi]          | [isi]          | [analisis] |
| COUNT Rows                | [isi]          | [isi]          | [analisis] |
| UPDATE (1 mahasiswa)      | [isi]          | [isi]          | [analisis] |
| DELETE (1 mahasiswa)      | [isi]          | [isi]          | [analisis] |
| Full Table Scan           | [isi]          | [isi]          | [analisis] |
| Storage Size (MB)         | [isi]          | [isi]          | [analisis] |
+---------------------------+----------------+----------------+------------+
*/

-- ============================================
-- KESIMPULAN EXPECTED
-- ============================================
/*
1NF (DENORMALIZED) MENANG:
✅ Simple SELECT (3-5x lebih cepat)
✅ LIKE Search (2-3x lebih cepat)
✅ Aggregation (2x lebih cepat)
✅ COUNT Rows (hampir sama)
✅ Full Table Scan (sedikit lebih cepat)

3NF (NORMALIZED) MENANG:
✅ UPDATE (50-100x lebih cepat!) ⭐⭐⭐
✅ DELETE (dengan CASCADE, lebih aman & konsisten)
✅ Storage Size (60-70% lebih hemat) ⭐⭐⭐
✅ Data Integrity (Foreign Key mencegah data korup)
✅ Maintenance (update 1 tempat, efek ke semua relasi)

KAPAN PAKAI 1NF?
- Read-heavy applications (99% SELECT, 1% UPDATE)
- Data Warehouse / OLAP (analytic, reporting)
- Data yang sudah "final" (tidak berubah lagi)

KAPAN PAKAI 3NF?
- Transactional systems / OLTP (banyak INSERT/UPDATE/DELETE) ⭐
- Data sering berubah (sistem akademik, e-commerce, banking)
- Data integrity sangat penting (tidak boleh inkonsisten)
*/