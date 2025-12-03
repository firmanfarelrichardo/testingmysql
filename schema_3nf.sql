-- ============================================
-- DATABASE SCHEMA: 3NF (NORMALIZED)
-- ============================================
-- Deskripsi:
--   Database ini mengikuti prinsip normalisasi Third Normal Form (3NF).
--   Data dipecah menjadi 4 tabel dengan relasi yang jelas.
--   
-- Karakteristik:
--   - Minimal duplikasi data (efisien storage)
--   - Integritas data terjaga dengan Foreign Key
--   - Update data lebih aman (tidak ada anomali)
--   - Query kompleks membutuhkan JOIN (bisa lebih lambat)
--   - Ideal untuk sistem transaksional (OLTP)
--
-- Tabel:
--   1. mahasiswa      -> Master data mahasiswa
--   2. dosen          -> Master data dosen
--   3. mata_kuliah    -> Master data mata kuliah (dengan relasi ke dosen)
--   4. krs            -> Tabel transaksi (relasi mahasiswa <-> mata kuliah)
-- ============================================

-- Drop tables jika sudah ada (untuk re-run script)
-- Urutan drop: child dulu, parent terakhir (karena FK constraint)
DROP TABLE IF EXISTS krs;
DROP TABLE IF EXISTS mata_kuliah;
DROP TABLE IF EXISTS dosen;
DROP TABLE IF EXISTS mahasiswa;

-- ============================================
-- TABEL 1: MAHASISWA
-- ============================================
CREATE TABLE mahasiswa (
    nim VARCHAR(20) PRIMARY KEY,
    nama_lengkap VARCHAR(100) NOT NULL,
    
    -- Index untuk mempercepat pencarian berdasarkan nama
    INDEX idx_nama (nama_lengkap)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Master data mahasiswa (1000 records)';

-- ============================================
-- TABEL 2: DOSEN
-- ============================================
CREATE TABLE dosen (
    nidn VARCHAR(20) PRIMARY KEY,
    nama_lengkap VARCHAR(100) NOT NULL,
    no_hp VARCHAR(20),
    
    -- Index untuk mempercepat pencarian berdasarkan nama
    INDEX idx_nama (nama_lengkap)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Master data dosen pengajar (50 records)';

-- ============================================
-- TABEL 3: MATA_KULIAH
-- ============================================
CREATE TABLE mata_kuliah (
    kode_mk VARCHAR(10) PRIMARY KEY,
    nama_mk VARCHAR(100) NOT NULL,
    sks INT NOT NULL CHECK (sks BETWEEN 1 AND 6),
    nidn_dosen VARCHAR(20) NOT NULL,
    
    -- Foreign Key: Setiap mata kuliah HARUS diampu oleh satu dosen
    CONSTRAINT fk_mk_dosen FOREIGN KEY (nidn_dosen) 
        REFERENCES dosen(nidn)
        ON DELETE RESTRICT  -- Tidak boleh hapus dosen jika masih mengajar
        ON UPDATE CASCADE,  -- Jika NIDN dosen berubah, update otomatis
    
    -- Index untuk mempercepat join
    INDEX idx_nama_mk (nama_mk),
    INDEX idx_nidn_dosen (nidn_dosen)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Master data mata kuliah (100 records)';

-- ============================================
-- TABEL 4: KRS (Kartu Rencana Studi)
-- ============================================
CREATE TABLE krs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nim VARCHAR(20) NOT NULL,
    kode_mk VARCHAR(10) NOT NULL,
    
    -- Foreign Keys: Tabel transaksi yang menghubungkan mahasiswa dengan mata kuliah
    CONSTRAINT fk_krs_mahasiswa FOREIGN KEY (nim) 
        REFERENCES mahasiswa(nim)
        ON DELETE CASCADE   -- Jika mahasiswa dihapus, KRS-nya ikut terhapus
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_krs_matakuliah FOREIGN KEY (kode_mk) 
        REFERENCES mata_kuliah(kode_mk)
        ON DELETE CASCADE   -- Jika MK dihapus, KRS-nya ikut terhapus
        ON UPDATE CASCADE,
    
    -- Constraint: Satu mahasiswa tidak boleh mengambil MK yang sama 2x
    UNIQUE KEY unique_krs (nim, kode_mk),
    
    -- Index untuk mempercepat query
    INDEX idx_nim (nim),
    INDEX idx_kode_mk (kode_mk)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Tabel transaksi KRS (10,000+ records)';

-- ============================================
-- CARA IMPORT DATA SQL DUMP KE DATABASE INI:
-- ============================================
-- Method 1: Menggunakan MySQL Command Line
-- mysql -u root -p nama_database < data_3nf.sql

-- Method 2: Menggunakan MySQL Workbench
-- 1. File -> Run SQL Script
-- 2. Pilih file data_3nf.sql
-- 3. Execute

-- Method 3: Menggunakan SOURCE command di MySQL CLI
-- SOURCE C:/path/to/data_3nf.sql;

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
-- SELECT m.nim, m.nama_lengkap, COUNT(k.kode_mk) AS jumlah_mk
-- FROM mahasiswa m
-- LEFT JOIN krs k ON m.nim = k.nim
-- GROUP BY m.nim, m.nama_lengkap
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
--                                        |
--                                        | (N:1)
--                                        |
--                                    dosen (1)
--
-- Keterangan:
-- - Satu mahasiswa bisa mengambil banyak mata kuliah (1:N via KRS)
-- - Satu mata kuliah bisa diambil banyak mahasiswa (N:M via KRS)
-- - Satu mata kuliah diampu oleh satu dosen (N:1)
-- - Satu dosen bisa mengampu banyak mata kuliah (1:N)
-- ============================================
