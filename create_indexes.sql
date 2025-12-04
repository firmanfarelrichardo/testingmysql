-- ============================================
-- CREATE ALL INDEXES: Buat Ulang Semua Index
-- ============================================
-- Deskripsi:
--   Script ini akan membuat kembali semua index yang telah dihapus
--   untuk optimasi performa query.
--
--   Gunakan file ini setelah menjalankan drop_indexes.sql
--   untuk mengembalikan index seperti semula.
--
-- Cara Penggunaan:
--   Method 1 (MySQL Command Line):
--     mysql -u root -p experiment_db < create_indexes.sql
--
--   Method 2 (MySQL Workbench):
--     1. File → Run SQL Script
--     2. Pilih file create_indexes.sql
--     3. Execute
--
-- Gunakan script ini untuk:
--   - Membuat ulang index setelah dihapus
--   - Optimasi performa query
--   - Testing performa dengan index
-- ============================================

USE experiment_db;

-- ============================================
-- BAGIAN 1: CREATE INDEX UNTUK TABEL 1NF
-- ============================================

SELECT 'Membuat index untuk tabel_krs_1nf...' AS status;

-- Buat index untuk tabel_krs_1nf
CREATE INDEX idx_nim ON tabel_krs_1nf(nim);
CREATE INDEX idx_kode_mk ON tabel_krs_1nf(kode_mk);
CREATE INDEX idx_nidn_dosen ON tabel_krs_1nf(nidn_dosen);
CREATE INDEX idx_nama_mhs ON tabel_krs_1nf(nama_mhs);

SELECT '✅ Index pada tabel_krs_1nf berhasil dibuat' AS status;

-- ============================================
-- BAGIAN 2: CREATE INDEX UNTUK TABEL 3NF
-- ============================================

SELECT 'Membuat index untuk tabel-tabel 3NF...' AS status;

-- Buat index untuk tabel mahasiswa
SET @create1 = IF((SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'experiment_db' AND TABLE_NAME = 'mahasiswa' AND INDEX_NAME = 'idx_nama') = 0, 'CREATE INDEX idx_nama ON mahasiswa(nama_lengkap)', 'SELECT "Index idx_nama sudah ada di mahasiswa" AS info');
PREPARE stmt1 FROM @create1;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

-- Buat index untuk tabel dosen
SET @create2 = IF((SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'experiment_db' AND TABLE_NAME = 'dosen' AND INDEX_NAME = 'idx_nama') = 0, 'CREATE INDEX idx_nama ON dosen(nama_lengkap)', 'SELECT "Index idx_nama sudah ada di dosen" AS info');
PREPARE stmt2 FROM @create2;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;

-- Buat index untuk tabel mata_kuliah
SET @create3 = IF((SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'experiment_db' AND TABLE_NAME = 'mata_kuliah' AND INDEX_NAME = 'idx_nama_mk') = 0, 'CREATE INDEX idx_nama_mk ON mata_kuliah(nama_mk)', 'SELECT "Index idx_nama_mk sudah ada" AS info');
PREPARE stmt3 FROM @create3;
EXECUTE stmt3;
DEALLOCATE PREPARE stmt3;

-- idx_nidn_dosen sudah ada (dibuat otomatis dari FK constraint ke tabel dosen)
SELECT 'ℹ️ Index idx_nidn_dosen di mata_kuliah sudah ada (dari FK constraint)' AS info;

-- Buat index untuk tabel krs
-- idx_nim dan idx_kode_mk sudah ada (dibuat otomatis dari FK constraint)
SELECT 'ℹ️ Index idx_nim di krs sudah ada (dari FK constraint)' AS info;
SELECT 'ℹ️ Index idx_kode_mk di krs sudah ada (dari FK constraint)' AS info;

SELECT '✅ Index pada semua tabel 3NF berhasil dibuat' AS status;

-- ============================================
-- BAGIAN 3: VERIFIKASI INDEX
-- ============================================

SELECT 'Verifikasi index yang telah dibuat:' AS info;

-- Cek semua index yang ada
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    CASE 
        WHEN INDEX_NAME = 'PRIMARY' THEN 'Primary Key'
        WHEN NON_UNIQUE = 0 THEN 'Unique/FK Constraint'
        ELSE 'Index (for optimization)'
    END AS index_type
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'experiment_db'
    AND TABLE_NAME IN ('tabel_krs_1nf', 'mahasiswa', 'dosen', 'mata_kuliah', 'krs')
ORDER BY TABLE_NAME, INDEX_NAME;

-- Hitung total index per tabel
SELECT 
    TABLE_NAME,
    COUNT(DISTINCT INDEX_NAME) AS total_indexes
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'experiment_db'
    AND TABLE_NAME IN ('tabel_krs_1nf', 'mahasiswa', 'dosen', 'mata_kuliah', 'krs')
GROUP BY TABLE_NAME
ORDER BY TABLE_NAME;

-- ============================================
-- INFORMASI INDEX YANG DIBUAT
-- ============================================
/*
INDEX YANG DIBUAT:

Tabel: tabel_krs_1nf
  ✅ idx_nim          - Mempercepat pencarian berdasarkan NIM
  ✅ idx_kode_mk      - Mempercepat pencarian berdasarkan kode MK
  ✅ idx_nidn_dosen   - Mempercepat pencarian berdasarkan NIDN dosen
  ✅ idx_nama_mhs     - Mempercepat pencarian berdasarkan nama mahasiswa

Tabel: mahasiswa
  ✅ idx_nama         - Mempercepat pencarian berdasarkan nama

Tabel: dosen
  ✅ idx_nama         - Mempercepat pencarian berdasarkan nama

Tabel: mata_kuliah
  ✅ idx_nama_mk      - Mempercepat pencarian berdasarkan nama MK
  ℹ️ idx_nidn_dosen   - Sudah ada (dari FK constraint ke dosen)

Tabel: krs
  ℹ️ idx_nim          - Sudah ada (dari FK constraint ke mahasiswa)
  ℹ️ idx_kode_mk      - Sudah ada (dari FK constraint ke mata_kuliah)

MANFAAT INDEX:
  - Mempercepat query SELECT dengan WHERE clause
  - Mempercepat operasi JOIN
  - Mempercepat ORDER BY dan GROUP BY
  - Meningkatkan performa query kompleks

TRADE-OFF:
  - Sedikit memperlambat INSERT/UPDATE/DELETE (perlu update index)
  - Menambah ukuran storage database
  - Untuk database transactional, trade-off ini worth it!
*/

-- ============================================
-- SELESAI!
-- ============================================
SELECT 'Semua index berhasil dibuat!' AS status,
       'Database siap untuk query dengan performa optimal' AS info;
