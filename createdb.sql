CREATE DATABASE experiment_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE experiment_db;



-- Hapus data lama (tapi JANGAN drop table)
SET FOREIGN_KEY_CHECKS = 0;  -- Disable FK sementara
TRUNCATE TABLE krs;
TRUNCATE TABLE mata_kuliah;
TRUNCATE TABLE dosen;
TRUNCATE TABLE mahasiswa;
TRUNCATE TABLE tabel_krs_1nf;
SET FOREIGN_KEY_CHECKS = 1;  -- Enable kembali

SELECT COUNT(*) FROM mahasiswa;   -- Should be 1000
SELECT COUNT(*) FROM dosen;       -- Should be 50
SELECT COUNT(*) FROM mata_kuliah; -- Should be 100
SELECT COUNT(*) FROM krs;         -- Should be 10000+





-- ============================================
-- IMPORT DATA CSV KE TABEL 1NF
-- Enable local_infile dulu
SET GLOBAL local_infile = 1;

-- Exit MySQL, lalu login ulang dengan flag:
-- mysql --local-infile=1 -u root -p

USE experiment_db;

LOAD DATA LOCAL INFILE 'C:/Users/ASUS/Documents/SEMESTER 5/Basis Data Lanjut/TestingKRS/data_1nf.csv'
INTO TABLE tabel_krs_1nf
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(nim, nama_mhs, kode_mk, nama_mk, sks, nidn_dosen, nama_dosen, nohp_mhs);

SELECT COUNT(*) FROM tabel_krs_1nf;  -- Harusnya 10000