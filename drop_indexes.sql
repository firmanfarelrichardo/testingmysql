-- ============================================
-- DROP ALL INDEXES: Hapus Semua Index dari Database
-- ============================================
-- Deskripsi:
--   Script ini akan menghapus semua index yang telah dibuat
--   pada tabel-tabel di database experiment_db.
--
--   PENTING: Script ini TIDAK menghapus:
--   - Primary Key
--   - Foreign Key constraints
--   - Unique constraints
--
--   Yang dihapus hanya INDEX biasa untuk optimasi query.
--
-- Cara Penggunaan:
--   Method 1 (MySQL Command Line):
--     mysql -u root -p experiment_db < drop_indexes.sql
--
--   Method 2 (MySQL Workbench):
--     1. File → Run SQL Script
--     2. Pilih file drop_indexes.sql
--     3. Execute
--
-- Gunakan script ini untuk:
--   - Mengembalikan database ke kondisi tanpa index
--   - Testing performa query tanpa index vs dengan index
--   - Membandingkan kecepatan query sebelum dan sesudah indexing
-- ============================================

USE experiment_db;

-- ============================================
-- BAGIAN 1: DROP INDEX DARI TABEL 1NF
-- ============================================

SELECT 'Menghapus index dari tabel_krs_1nf...' AS status;

-- Drop index dari tabel_krs_1nf (jika ada)
-- Gunakan procedure untuk menghindari error jika index tidak ada
SET @drop1 = IF((SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'experiment_db' AND TABLE_NAME = 'tabel_krs_1nf' AND INDEX_NAME = 'idx_nim') > 0, 'ALTER TABLE tabel_krs_1nf DROP INDEX idx_nim', 'SELECT "Index idx_nim tidak ada" AS info');
PREPARE stmt1 FROM @drop1;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

SET @drop2 = IF((SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'experiment_db' AND TABLE_NAME = 'tabel_krs_1nf' AND INDEX_NAME = 'idx_kode_mk') > 0, 'ALTER TABLE tabel_krs_1nf DROP INDEX idx_kode_mk', 'SELECT "Index idx_kode_mk tidak ada" AS info');
PREPARE stmt2 FROM @drop2;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;

SET @drop3 = IF((SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'experiment_db' AND TABLE_NAME = 'tabel_krs_1nf' AND INDEX_NAME = 'idx_nidn_dosen') > 0, 'ALTER TABLE tabel_krs_1nf DROP INDEX idx_nidn_dosen', 'SELECT "Index idx_nidn_dosen tidak ada" AS info');
PREPARE stmt3 FROM @drop3;
EXECUTE stmt3;
DEALLOCATE PREPARE stmt3;

SET @drop4 = IF((SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'experiment_db' AND TABLE_NAME = 'tabel_krs_1nf' AND INDEX_NAME = 'idx_nama_mhs') > 0, 'ALTER TABLE tabel_krs_1nf DROP INDEX idx_nama_mhs', 'SELECT "Index idx_nama_mhs tidak ada" AS info');
PREPARE stmt4 FROM @drop4;
EXECUTE stmt4;
DEALLOCATE PREPARE stmt4;

SELECT '✅ Index pada tabel_krs_1nf sudah diproses' AS status;

-- ============================================
-- BAGIAN 2: DROP INDEX DARI TABEL 3NF
-- ============================================

SELECT 'Menghapus index dari tabel-tabel 3NF...' AS status;

-- Drop index dari tabel mahasiswa (jika ada)
SET @drop5 = IF((SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'experiment_db' AND TABLE_NAME = 'mahasiswa' AND INDEX_NAME = 'idx_nama') > 0, 'ALTER TABLE mahasiswa DROP INDEX idx_nama', 'SELECT "Index idx_nama tidak ada di mahasiswa" AS info');
PREPARE stmt5 FROM @drop5;
EXECUTE stmt5;
DEALLOCATE PREPARE stmt5;

-- Drop index dari tabel dosen (jika ada)
SET @drop6 = IF((SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'experiment_db' AND TABLE_NAME = 'dosen' AND INDEX_NAME = 'idx_nama') > 0, 'ALTER TABLE dosen DROP INDEX idx_nama', 'SELECT "Index idx_nama tidak ada di dosen" AS info');
PREPARE stmt6 FROM @drop6;
EXECUTE stmt6;
DEALLOCATE PREPARE stmt6;

-- Drop index dari tabel mata_kuliah (jika ada)
SET @drop7 = IF((SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'experiment_db' AND TABLE_NAME = 'mata_kuliah' AND INDEX_NAME = 'idx_nama_mk') > 0, 'ALTER TABLE mata_kuliah DROP INDEX idx_nama_mk', 'SELECT "Index idx_nama_mk tidak ada" AS info');
PREPARE stmt7 FROM @drop7;
EXECUTE stmt7;
DEALLOCATE PREPARE stmt7;

-- idx_nidn_dosen adalah bagian dari foreign key constraint, jadi tidak bisa dihapus
-- Index ini akan otomatis dihapus jika foreign key constraint dihapus
SELECT 'ℹ️ Index idx_nidn_dosen di mata_kuliah tidak dihapus (bagian dari FK constraint)' AS info;

-- Drop index dari tabel krs (jika ada)
-- Catatan: idx_nim dan idx_kode_mk adalah bagian dari FK constraint, tidak bisa dihapus
-- Index FK akan otomatis dihapus jika FK constraint dihapus

SELECT 'ℹ️ Index idx_nim di krs tidak dihapus (bagian dari FK constraint)' AS info;
SELECT 'ℹ️ Index idx_kode_mk di krs tidak dihapus (bagian dari FK constraint)' AS info;

SELECT '✅ Index pada semua tabel 3NF sudah diproses' AS status;

-- ============================================
-- BAGIAN 3: VERIFIKASI INDEX YANG TERSISA
-- ============================================

SELECT 'Verifikasi index yang tersisa (seharusnya hanya PK, FK, dan UNIQUE):' AS info;

-- Cek index yang masih ada di semua tabel
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    CASE 
        WHEN INDEX_NAME = 'PRIMARY' THEN 'Primary Key'
        WHEN NON_UNIQUE = 0 THEN 'Unique Constraint'
        WHEN INDEX_NAME LIKE 'fk_%' THEN 'Foreign Key'
        ELSE 'Index'
    END AS index_type
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'experiment_db'
    AND TABLE_NAME IN ('tabel_krs_1nf', 'mahasiswa', 'dosen', 'mata_kuliah', 'krs')
ORDER BY TABLE_NAME, INDEX_NAME;

-- ============================================
-- INFORMASI TAMBAHAN
-- ============================================
/*
INDEX YANG DIHAPUS:

Tabel: tabel_krs_1nf
  - idx_nim
  - idx_kode_mk
  - idx_nidn_dosen
  - idx_nama_mhs

Tabel: mahasiswa
  - idx_nama

Tabel: dosen
  - idx_nama

Tabel: mata_kuliah
  - idx_nama_mk
  - idx_nidn_dosen

Tabel: krs
  - idx_nim
  - idx_kode_mk

INDEX YANG TETAP ADA (tidak dihapus):
  - PRIMARY KEY pada semua tabel
  - FOREIGN KEY constraints (fk_mk_dosen, fk_krs_mahasiswa, fk_krs_matakuliah)
  - UNIQUE KEY (unique_krs pada tabel krs)

CARA MEMBUAT ULANG INDEX:
Jika ingin membuat kembali index yang telah dihapus,
jalankan file create_indexes.sql atau setup_database.sql
*/

-- ============================================
-- SELESAI!
-- ============================================
SELECT 'Semua index berhasil dihapus!' AS status,
       'Database siap untuk testing tanpa index' AS info;
