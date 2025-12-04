-- Schema 1NF (Denormalized/Flat Table)
-- Data duplikasi tinggi, query SELECT cepat, UPDATE berisiko

DROP TABLE IF EXISTS tabel_krs_1nf;
CREATE TABLE tabel_krs_1nf (
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- Data Mahasiswa (akan duplikat untuk setiap mata kuliah yang diambil)
    nim VARCHAR(20) NOT NULL,
    nama_mhs VARCHAR(100) NOT NULL,
    nohp_mhs VARCHAR(20) NOT NULL,
    kode_mk VARCHAR(10) NOT NULL,
    nama_mk VARCHAR(100) NOT NULL,
    sks INT NOT NULL,
    nidn_dosen VARCHAR(20) NOT NULL,
    nama_dosen VARCHAR(100) NOT NULL,
    INDEX idx_nim (nim),
    INDEX idx_kode_mk (kode_mk),
    INDEX idx_nidn_dosen (nidn_dosen),
    INDEX idx_nama_mhs (nama_mhs)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
