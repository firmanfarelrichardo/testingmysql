-- Drop All Indexes (Hapus index optimasi, PK/FK tetap ada)
-- Penggunaan: mysql -u root -p experiment_db < drop_indexes.sql

USE experiment_db;

-- Drop index dari tabel 1NF
SELECT 'Menghapus index dari tabel_krs_1nf...' AS status;

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

-- Drop index dari tabel 3NF
SELECT 'Menghapus index dari tabel-tabel 3NF...' AS status;

SET @drop5 = IF((SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'experiment_db' AND TABLE_NAME = 'mahasiswa' AND INDEX_NAME = 'idx_nama') > 0, 'ALTER TABLE mahasiswa DROP INDEX idx_nama', 'SELECT "Index idx_nama tidak ada di mahasiswa" AS info');
PREPARE stmt5 FROM @drop5;
EXECUTE stmt5;
DEALLOCATE PREPARE stmt5;

SET @drop6 = IF((SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'experiment_db' AND TABLE_NAME = 'dosen' AND INDEX_NAME = 'idx_nama') > 0, 'ALTER TABLE dosen DROP INDEX idx_nama', 'SELECT "Index idx_nama tidak ada di dosen" AS info');
PREPARE stmt6 FROM @drop6;
EXECUTE stmt6;
DEALLOCATE PREPARE stmt6;

SET @drop7 = IF((SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'experiment_db' AND TABLE_NAME = 'mata_kuliah' AND INDEX_NAME = 'idx_nama_mk') > 0, 'ALTER TABLE mata_kuliah DROP INDEX idx_nama_mk', 'SELECT "Index idx_nama_mk tidak ada" AS info');
PREPARE stmt7 FROM @drop7;
EXECUTE stmt7;
DEALLOCATE PREPARE stmt7;

SELECT 'ℹ️ Index idx_nidn_dosen di mata_kuliah tidak dihapus (bagian dari FK constraint)' AS info;
SELECT 'ℹ️ Index idx_nim di krs tidak dihapus (bagian dari FK constraint)' AS info;
SELECT 'ℹ️ Index idx_kode_mk di krs tidak dihapus (bagian dari FK constraint)' AS info;

SELECT '✅ Index pada semua tabel 3NF sudah diproses' AS status;

-- Verifikasi index yang tersisa
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

SELECT 'Semua index berhasil dihapus!' AS status, 'Database siap untuk testing tanpa index' AS info;
