-- Testing Performa: 1NF vs 3NF
-- Jalankan query satu per satu, catat Duration, bandingkan hasil

USE experiment_db;

-- Persiapan (jalankan sebelum setiap test)
RESET QUERY CACHE;
SET profiling = 1;

-- TEST 1: Simple SELECT (KRS 1 Mahasiswa)
-- 1A: 1NF
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

-- 1B: 3NF
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

-- TEST 2: LIKE Search (Cari nama "Siti")
-- 2A: 1NF
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

-- 2B: 3NF
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

-- TEST 3: Aggregation (Total SKS per Dosen)
-- 3A: 1NF
SELECT SQL_NO_CACHE 
    nidn_dosen,
    nama_dosen,
    SUM(DISTINCT sks) AS total_sks_diajar,
    COUNT(DISTINCT nim) AS jumlah_mahasiswa
FROM tabel_krs_1nf
GROUP BY nidn_dosen, nama_dosen
ORDER BY total_sks_diajar DESC, jumlah_mahasiswa DESC
LIMIT 20;

-- 3B: 3NF
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

-- TEST 4: Complex JOIN (Mata Kuliah Populer)
-- 4A: 1NF
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

-- 4B: 3NF
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

-- TEST 5: COUNT Rows
-- 5A: 1NF
SELECT SQL_NO_CACHE COUNT(*) AS total_krs
FROM tabel_krs_1nf;

-- 5B: 3NF
SELECT SQL_NO_CACHE COUNT(*) AS total_krs
FROM krs;

-- TEST 6: UPDATE (Update Anomaly)
-- 6A: 1NF (banyak row)
SELECT COUNT(*) AS jumlah_row_akan_diupdate
FROM tabel_krs_1nf
WHERE nim = '202000001';

CREATE TEMPORARY TABLE backup_1nf AS
SELECT * FROM tabel_krs_1nf WHERE nim = '202000001';

UPDATE tabel_krs_1nf
SET nohp_mhs = '0811-9999-9999'
WHERE nim = '202000001';

UPDATE tabel_krs_1nf t
INNER JOIN backup_1nf b ON t.nim = b.nim AND t.kode_mk = b.kode_mk
SET t.nohp_mhs = b.nohp_mhs;

DROP TEMPORARY TABLE backup_1nf;

-- 6B: 3NF (1 row saja)
SELECT nim, nama_lengkap, nohp_mhs
FROM mahasiswa
WHERE nim = '202000001';

UPDATE mahasiswa
SET nohp_mhs = '0811-9999-9999'
WHERE nim = '202000001';

UPDATE mahasiswa
SET nohp_mhs = (
    SELECT nohp_mhs FROM (
        SELECT nohp_mhs FROM mahasiswa WHERE nim = '202000001'
    ) AS temp
)
WHERE nim = '202000001';

-- TEST 7: DELETE (Hapus Data Mahasiswa)
-- 7A: 1NF (manual hapus semua row)
SELECT COUNT(*) AS jumlah_row_akan_dihapus
FROM tabel_krs_1nf
WHERE nim = '202000999';

CREATE TEMPORARY TABLE backup_delete_1nf AS
SELECT * FROM tabel_krs_1nf WHERE nim = '202000999';

DELETE FROM tabel_krs_1nf
WHERE nim = '202000999';

INSERT INTO tabel_krs_1nf SELECT * FROM backup_delete_1nf;
DROP TEMPORARY TABLE backup_delete_1nf;

-- 7B: 3NF (CASCADE otomatis)
SELECT m.nim, m.nama_lengkap, COUNT(k.kode_mk) AS jumlah_mk
FROM mahasiswa m
LEFT JOIN krs k ON m.nim = k.nim
WHERE m.nim = '202000999'
GROUP BY m.nim, m.nama_lengkap;

CREATE TEMPORARY TABLE backup_mhs AS
SELECT * FROM mahasiswa WHERE nim = '202000999';

CREATE TEMPORARY TABLE backup_krs AS
SELECT * FROM krs WHERE nim = '202000999';

DELETE FROM mahasiswa
WHERE nim = '202000999';

INSERT INTO mahasiswa SELECT * FROM backup_mhs;
INSERT INTO krs SELECT nim, kode_mk FROM backup_krs;

DROP TEMPORARY TABLE backup_mhs;
DROP TEMPORARY TABLE backup_krs;

-- TEST 8: Full Table Scan
-- 8A: 1NF
SELECT SQL_NO_CACHE COUNT(*) 
FROM tabel_krs_1nf;

-- 8B: 3NF
SELECT SQL_NO_CACHE COUNT(*) 
FROM mahasiswa m
INNER JOIN krs k ON m.nim = k.nim
INNER JOIN mata_kuliah mk ON k.kode_mk = mk.kode_mk
INNER JOIN dosen d ON mk.nidn_dosen = d.nidn;

-- TEST 9: Storage Size
SELECT 
    table_name AS 'Nama Tabel',
    ROUND((data_length + index_length) / 1024 / 1024, 2) AS 'Ukuran (MB)',
    table_rows AS 'Jumlah Baris',
    ROUND((data_length + index_length) / table_rows, 2) AS 'Bytes per Row'
FROM information_schema.TABLES
WHERE table_schema = 'experiment_db'
    AND table_name IN ('tabel_krs_1nf', 'mahasiswa', 'dosen', 'mata_kuliah', 'krs')
ORDER BY (data_length + index_length) DESC;

-- TEST 10: Profiling
SHOW PROFILES;

-- Detail query tertentu: SHOW PROFILE FOR QUERY X;