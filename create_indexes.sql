-- Create All Indexes (Buat ulang index untuk optimasi)
-- Penggunaan: mysql -u root -p experiment_db < create_indexes.sql

USE experiment_db;

-- Create index untuk tabel 1NF
SELECT 'Membuat index untuk tabel_krs_1nf...' AS status;

CREATE INDEX idx_nim ON tabel_krs_1nf(nim);
CREATE INDEX idx_kode_mk ON tabel_krs_1nf(kode_mk);
CREATE INDEX idx_nidn_dosen ON tabel_krs_1nf(nidn_dosen);
CREATE INDEX idx_nama_mhs ON tabel_krs_1nf(nama_mhs);

SELECT '✅ Index pada tabel_krs_1nf berhasil dibuat' AS status;

-- Create index untuk tabel 3NF
SELECT 'Membuat index untuk tabel-tabel 3NF...' AS status;

SET @create1 = IF((SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'experiment_db' AND TABLE_NAME = 'mahasiswa' AND INDEX_NAME = 'idx_nama') = 0, 'CREATE INDEX idx_nama ON mahasiswa(nama_lengkap)', 'SELECT "Index idx_nama sudah ada di mahasiswa" AS info');
PREPARE stmt1 FROM @create1;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

SET @create2 = IF((SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'experiment_db' AND TABLE_NAME = 'dosen' AND INDEX_NAME = 'idx_nama') = 0, 'CREATE INDEX idx_nama ON dosen(nama_lengkap)', 'SELECT "Index idx_nama sudah ada di dosen" AS info');
PREPARE stmt2 FROM @create2;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;

SET @create3 = IF((SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = 'experiment_db' AND TABLE_NAME = 'mata_kuliah' AND INDEX_NAME = 'idx_nama_mk') = 0, 'CREATE INDEX idx_nama_mk ON mata_kuliah(nama_mk)', 'SELECT "Index idx_nama_mk sudah ada" AS info');
PREPARE stmt3 FROM @create3;
EXECUTE stmt3;
DEALLOCATE PREPARE stmt3;

SELECT 'ℹ️ Index idx_nidn_dosen di mata_kuliah sudah ada (dari FK constraint)' AS info;
SELECT 'ℹ️ Index idx_nim di krs sudah ada (dari FK constraint)' AS info;
SELECT 'ℹ️ Index idx_kode_mk di krs sudah ada (dari FK constraint)' AS info;

SELECT '✅ Index pada semua tabel 3NF berhasil dibuat' AS status;

-- Verifikasi index
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

SELECT 
    TABLE_NAME,
    COUNT(DISTINCT INDEX_NAME) AS total_indexes
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'experiment_db'
    AND TABLE_NAME IN ('tabel_krs_1nf', 'mahasiswa', 'dosen', 'mata_kuliah', 'krs')
GROUP BY TABLE_NAME
ORDER BY TABLE_NAME;

SELECT 'Semua index berhasil dibuat!' AS status, 'Database siap untuk query dengan performa optimal' AS info;
