-- ============================================
-- SETUP DATABASE LENGKAP: 1NF vs 3NF Experiment
-- ============================================
-- Deskripsi:
--   Script ini akan membuat database experiment_db lengkap dengan:
--   1. Schema 1NF (tabel flat denormalized)
--   2. Schema 3NF (tabel normalized dengan relasi)
--   3. Import data untuk 3NF
--
-- Cara Penggunaan:
--   Method 1 (MySQL Command Line):
--     mysql -u root -p < setup_database.sql
--
--   Method 2 (MySQL Workbench):
--     1. File → Run SQL Script
--     2. Pilih file setup_database.sql
--     3. Execute
--
-- Setelah menjalankan script ini:
--   - Database experiment_db sudah siap
--   - Tabel 1NF & 3NF sudah dibuat
--   - Data 3NF sudah diimport
--   - Tinggal import data_1nf.csv via Import Wizard
-- ============================================

-- Drop database jika sudah ada (untuk fresh install)
DROP DATABASE IF EXISTS experiment_db;

-- Buat database baru
CREATE DATABASE experiment_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- Gunakan database
USE experiment_db;

-- ============================================
-- BAGIAN 1: SCHEMA 1NF (DENORMALIZED)
-- ============================================

-- Drop table jika sudah ada
DROP TABLE IF EXISTS tabel_krs_1nf;

-- Buat tabel flat (denormalized)
CREATE TABLE tabel_krs_1nf (
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- Data Mahasiswa (akan duplikat untuk setiap mata kuliah yang diambil)
    nim VARCHAR(20) NOT NULL,
    nama_mhs VARCHAR(100) NOT NULL,
    nohp_mhs VARCHAR(20) NOT NULL,
    
    -- Data Mata Kuliah
    kode_mk VARCHAR(10) NOT NULL,
    nama_mk VARCHAR(100) NOT NULL,
    sks INT NOT NULL,
    
    -- Data Dosen (akan duplikat untuk setiap mahasiswa yang mengambil MK ini)
    nidn_dosen VARCHAR(20) NOT NULL,
    nama_dosen VARCHAR(100) NOT NULL,
    
    -- Index untuk mempercepat query
    INDEX idx_nim (nim),
    INDEX idx_kode_mk (kode_mk),
    INDEX idx_nidn_dosen (nidn_dosen),
    INDEX idx_nama_mhs (nama_mhs)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Tabel 1NF - Denormalized flat table untuk experiment';

-- ============================================
-- BAGIAN 2: SCHEMA 3NF (NORMALIZED)
-- ============================================

-- Drop tables jika sudah ada (urutan child dulu, parent terakhir)
DROP TABLE IF EXISTS krs;
DROP TABLE IF EXISTS mata_kuliah;
DROP TABLE IF EXISTS dosen;
DROP TABLE IF EXISTS mahasiswa;

-- TABEL 1: MAHASISWA
CREATE TABLE mahasiswa (
    nim VARCHAR(20) PRIMARY KEY,
    nama_lengkap VARCHAR(100) NOT NULL,
    nohp_mhs VARCHAR(20) NOT NULL COMMENT 'Nomor HP mahasiswa format Indonesia',
    
    INDEX idx_nama (nama_lengkap)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Master data mahasiswa (1000 records)';

-- TABEL 2: DOSEN
CREATE TABLE dosen (
    nidn VARCHAR(20) PRIMARY KEY,
    nama_lengkap VARCHAR(200) NOT NULL COMMENT 'Nama dosen dengan gelar akademik',
    
    INDEX idx_nama (nama_lengkap)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Master data dosen dengan gelar akademik (50 records)';

-- TABEL 3: MATA_KULIAH
CREATE TABLE mata_kuliah (
    kode_mk VARCHAR(10) PRIMARY KEY,
    nama_mk VARCHAR(100) NOT NULL,
    sks INT NOT NULL CHECK (sks BETWEEN 1 AND 6),
    nidn_dosen VARCHAR(20) NOT NULL,
    
    -- Foreign Key
    CONSTRAINT fk_mk_dosen FOREIGN KEY (nidn_dosen) 
        REFERENCES dosen(nidn)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    INDEX idx_nama_mk (nama_mk),
    INDEX idx_nidn_dosen (nidn_dosen)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Master data mata kuliah (100 records)';

-- TABEL 4: KRS (Kartu Rencana Studi)
CREATE TABLE krs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nim VARCHAR(20) NOT NULL,
    kode_mk VARCHAR(10) NOT NULL,
    
    -- Foreign Keys
    CONSTRAINT fk_krs_mahasiswa FOREIGN KEY (nim) 
        REFERENCES mahasiswa(nim)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_krs_matakuliah FOREIGN KEY (kode_mk) 
        REFERENCES mata_kuliah(kode_mk)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    -- Constraint: Satu mahasiswa tidak boleh mengambil MK yang sama 2x
    UNIQUE KEY unique_krs (nim, kode_mk),
    
    INDEX idx_nim (nim),
    INDEX idx_kode_mk (kode_mk)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Tabel transaksi KRS (10,000+ records)';

-- ============================================
-- BAGIAN 3: IMPORT DATA 3NF
-- ============================================
-- Data sudah ada di file data_3nf.sql
-- Jalankan file tersebut setelah ini atau gunakan SOURCE command

-- Jika ingin langsung import dari file ini, uncomment baris berikut:
-- SOURCE data_3nf.sql;

-- ============================================
-- BAGIAN 4: VERIFIKASI
-- ============================================

-- Tampilkan semua tabel yang sudah dibuat
SHOW TABLES;

-- Cek struktur tabel
DESCRIBE tabel_krs_1nf;
DESCRIBE mahasiswa;
DESCRIBE dosen;
DESCRIBE mata_kuliah;
DESCRIBE krs;

-- ============================================
-- INFORMASI SELANJUTNYA
-- ============================================
/*
LANGKAH SELANJUTNYA:

1. IMPORT DATA 3NF:
   - Di terminal: mysql -u root -p experiment_db < data_3nf.sql
   - Atau di Workbench: File → Run SQL Script → pilih data_3nf.sql

2. IMPORT DATA 1NF:
   - Di MySQL Workbench:
     a. Klik kanan tabel_krs_1nf → Table Data Import Wizard
     b. Pilih file data_1nf.csv
     c. Next → Next → Finish

3. VERIFIKASI DATA:
   SELECT 'Mahasiswa' AS tabel, COUNT(*) AS jumlah FROM mahasiswa
   UNION ALL
   SELECT 'Dosen', COUNT(*) FROM dosen
   UNION ALL
   SELECT 'Mata Kuliah', COUNT(*) FROM mata_kuliah
   UNION ALL
   SELECT 'KRS', COUNT(*) FROM krs
   UNION ALL
   SELECT '1NF Table', COUNT(*) FROM tabel_krs_1nf;

4. JALANKAN TESTING:
   - Buka file testing.sql
   - Jalankan query benchmark satu per satu
   - Catat hasilnya di tabel perbandingan

TROUBLESHOOTING:

Jika error "Access denied":
  - Pastikan user MySQL memiliki privilege CREATE DATABASE
  - Atau gunakan: GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost';

Jika error "Foreign key constraint":
  - Pastikan urutan import data benar (parent dulu, child kemudian)
  - Dosen → Mata Kuliah → Mahasiswa → KRS

Jika data_1nf.csv gagal import:
  - Pastikan encoding file adalah UTF-8
  - Pastikan delimiter adalah koma (,)
  - Cek apakah ada double quotes di data
*/

-- ============================================
-- SELESAI! Database siap digunakan.
-- ============================================
SELECT 'Database experiment_db berhasil dibuat!' AS status,
       'Silakan import data_3nf.sql dan data_1nf.csv' AS next_step;
