-- ============================================
-- DATABASE SCHEMA: 1NF (DENORMALIZED / FLAT TABLE)
-- ============================================
-- Deskripsi:
--   Tabel ini menyimpan SEMUA informasi dalam SATU tabel.
--   Mengakibatkan DUPLIKASI DATA yang sangat tinggi.
--   
-- Karakteristik:
--   - Tidak ada Foreign Key
--   - Tidak ada relasi antar tabel (karena cuma 1 tabel)
--   - Data mahasiswa dan dosen akan terulang berkali-kali
--   - Ukuran storage lebih besar
--   - Query SELECT sederhana lebih cepat (tidak perlu JOIN)
--   - UPDATE data berisiko inconsistency
-- ============================================

-- Drop table jika sudah ada (untuk re-run script)
DROP TABLE IF EXISTS tabel_krs_1nf;

-- Buat tabel flat (denormalized)
CREATE TABLE tabel_krs_1nf (
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- Data Mahasiswa (akan duplikat untuk setiap mata kuliah yang diambil)
    nim VARCHAR(20) NOT NULL,
    nama_mhs VARCHAR(100) NOT NULL,
    
    -- Data Mata Kuliah
    kode_mk VARCHAR(10) NOT NULL,
    nama_mk VARCHAR(100) NOT NULL,
    sks INT NOT NULL,
    
    -- Data Dosen (akan duplikat untuk setiap mahasiswa yang mengambil MK ini)
    nidn_dosen VARCHAR(20) NOT NULL,
    nama_dosen VARCHAR(100) NOT NULL,
    nohp_dosen VARCHAR(20) NOT NULL,
    
    -- Index untuk mempercepat query
    INDEX idx_nim (nim),
    INDEX idx_kode_mk (kode_mk),
    INDEX idx_nidn_dosen (nidn_dosen),
    INDEX idx_nama_mhs (nama_mhs)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- CARA IMPORT DATA CSV KE TABEL INI:
-- ============================================
-- Method 1: Menggunakan MySQL Command Line
-- LOAD DATA INFILE 'C:/path/to/data_1nf.csv'
-- INTO TABLE tabel_krs_1nf
-- FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (nim, nama_mhs, kode_mk, nama_mk, sks, nidn_dosen, nama_dosen, nohp_dosen);

-- Method 2: Menggunakan MySQL Workbench / phpMyAdmin
-- 1. Klik kanan pada tabel -> Table Data Import Wizard
-- 2. Pilih file data_1nf.csv
-- 3. Mapping kolom sesuai urutan
-- 4. Execute import

-- ============================================
-- CONTOH QUERY UNTUK CEK DATA
-- ============================================
-- SELECT COUNT(*) AS total_records FROM tabel_krs_1nf;
-- SELECT * FROM tabel_krs_1nf LIMIT 10;
