-- Schema 3NF (Normalized)
-- Minimal duplikasi, integritas terjaga, UPDATE aman

DROP TABLE IF EXISTS krs;
DROP TABLE IF EXISTS mata_kuliah;
DROP TABLE IF EXISTS dosen;
DROP TABLE IF EXISTS mahasiswa;

CREATE TABLE mahasiswa (
    nim VARCHAR(20) PRIMARY KEY,
    nama_lengkap VARCHAR(100) NOT NULL,
    nohp_mhs VARCHAR(20) NOT NULL,
    INDEX idx_nama (nama_lengkap)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE dosen (
    nidn VARCHAR(20) PRIMARY KEY,
    nama_lengkap VARCHAR(200) NOT NULL,
    INDEX idx_nama (nama_lengkap)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE mata_kuliah (
    kode_mk VARCHAR(10) PRIMARY KEY,
    nama_mk VARCHAR(100) NOT NULL,
    sks INT NOT NULL CHECK (sks BETWEEN 1 AND 6),
    nidn_dosen VARCHAR(20) NOT NULL,
    CONSTRAINT fk_mk_dosen FOREIGN KEY (nidn_dosen) 
        REFERENCES dosen(nidn)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    INDEX idx_nama_mk (nama_mk),
    INDEX idx_nidn_dosen (nidn_dosen)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE krs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nim VARCHAR(20) NOT NULL,
    kode_mk VARCHAR(10) NOT NULL,
    CONSTRAINT fk_krs_mahasiswa FOREIGN KEY (nim) 
        REFERENCES mahasiswa(nim)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_krs_matakuliah FOREIGN KEY (kode_mk) 
        REFERENCES mata_kuliah(kode_mk)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    UNIQUE KEY unique_krs (nim, kode_mk),
    INDEX idx_nim (nim),
    INDEX idx_kode_mk (kode_mk)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Tabel transaksi KRS (10,000+ records)';

-- ============================================
-- CARA IMPORT DATA SQL DUMP KE DATABASE INI:
-- ============================================
-- Method 1: Menggunakan MySQL Command Line (Windows CMD/PowerShell)
-- mysql -u root -p experiment_db < data_3nf.sql

-- Method 2: Menggunakan MySQL Workbench
-- 1. File -> Run SQL Script
-- 2. Pilih file data_3nf.sql
-- 3. Execute

-- Method 3: Menggunakan SOURCE command di MySQL CLI (RECOMMENDED)
-- mysql -u root -p
-- USE experiment_db;
-- SOURCE C:/Users/ASUS/Documents/SEMESTER 5/Basis Data Lanjut/TestingKRS/data_3nf.sql;

-- ============================================
-- CONTOH QUERY UNTUK CEK DATA & RELASI
-- ============================================

-- Cek jumlah data per tabel
-- SELECT 'Mahasiswa' AS tabel, COUNT(*) AS jumlah FROM mahasiswa
-- UNION ALL
-- SELECT 'Dosen', COUNT(*) FROM dosen
-- UNION ALL
-- SELECT 'Mata Kuliah', COUNT(*) FROM mata_kuliah
-- UNION ALL
-- SELECT 'KRS', COUNT(*) FROM krs;

-- Cek relasi: Mahasiswa dengan KRS-nya
-- SELECT m.nim, m.nama_lengkap, m.nohp_mhs, COUNT(k.kode_mk) AS jumlah_mk
-- FROM mahasiswa m
-- LEFT JOIN krs k ON m.nim = k.nim
-- GROUP BY m.nim, m.nama_lengkap, m.nohp_mhs
-- LIMIT 10;

-- Cek relasi: Dosen dengan Mata Kuliah yang diampu
-- SELECT d.nidn, d.nama_lengkap, COUNT(mk.kode_mk) AS jumlah_mk_diampu
-- FROM dosen d
-- LEFT JOIN mata_kuliah mk ON d.nidn = mk.nidn_dosen
-- GROUP BY d.nidn, d.nama_lengkap
-- ORDER BY jumlah_mk_diampu DESC;

-- ============================================
-- VISUALISASI RELASI (ERD)
-- ============================================
-- mahasiswa (1) ----< krs >---- (1) mata_kuliah
--   |nohp_mhs|                          |
--                                        | (N:1)
--                                        |
--                                    dosen (1)
--                                   |nama_lengkap|
--                                   (dengan gelar)
--
-- Keterangan:
-- - Satu mahasiswa bisa mengambil banyak mata kuliah (1:N via KRS)
-- - Satu mata kuliah bisa diambil banyak mahasiswa (N:M via KRS)
-- - Satu mata kuliah diampu oleh satu dosen (N:1)
-- - Satu dosen bisa mengampu banyak mata kuliah (1:N)
-- - Mahasiswa memiliki nomor HP (nohp_mhs)
-- - Dosen memiliki nama lengkap dengan gelar akademik
-- ============================================
