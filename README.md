# 🎓 EXPERIMENT DATABASE: 1NF vs 3NF
## Tugas Basis Data Lanjut - Universitas

---

## 📋 DESKRIPSI PROJECT

Project ini adalah implementasi lengkap untuk membuktikan **trade-off performa** antara:
- **1NF (First Normal Form / Denormalized):** Struktur flat table dengan banyak duplikasi
- **3NF (Third Normal Form / Normalized):** Struktur relasional dengan tabel terpisah

**Context:** Sistem Akademik - Mahasiswa mengambil Mata Kuliah (KRS)

---

## 📁 STRUKTUR FILE

```
TestingKRS/
│
├── generate_data.py           # Script Python untuk generate dummy data
├── schema_1nf.sql             # DDL untuk tabel flat (denormalized)
├── schema_3nf.sql             # DDL untuk tabel normalized (4 tabel)
├── benchmark_queries.sql      # Query untuk testing performa
├── ANALISIS_DAN_PANDUAN.md    # Analisis profesional & hipotesis
└── README.md                  # File ini
```

**Output Files (akan digenerate):**
```
├── data_1nf.csv               # Data CSV untuk import ke tabel 1NF
└── data_3nf.sql               # SQL dump untuk import ke 3NF
```

---

## 🚀 QUICK START GUIDE

### **STEP 1: Install Dependencies**

```bash
# Install Python library yang diperlukan
pip install faker
```

### **STEP 2: Generate Dummy Data**

```bash
# Jalankan script Python
python generate_data.py
```

**Output:**
- ✅ `data_1nf.csv` (untuk tabel flat)
- ✅ `data_3nf.sql` (untuk tabel normalized)

**Spesifikasi Data:**
- 1.000 Mahasiswa unik
- 50 Dosen unik
- 100 Mata Kuliah unik
- 10.000+ Transaksi KRS

### **STEP 3: Setup Database MySQL**

#### **A. Buat Database Baru**

```sql
CREATE DATABASE experiment_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE experiment_db;
```

#### **B. Import Schema 1NF**

**Cara 1: Via MySQL Workbench**
1. File → Open SQL Script → Pilih `schema_1nf.sql`
2. Execute Script (⚡ icon)

**Cara 2: Via Command Line**
```bash
mysql -u root -p experiment_db < schema_1nf.sql
```

#### **C. Import Schema 3NF**

**Cara 1: Via MySQL Workbench**
1. File → Open SQL Script → Pilih `schema_3nf.sql`
2. Execute Script (⚡ icon)

**Cara 2: Via Command Line**
```bash
mysql -u root -p experiment_db < schema_3nf.sql
```

**Verifikasi:**
```sql
SHOW TABLES;
-- Harusnya muncul: tabel_krs_1nf, mahasiswa, dosen, mata_kuliah, krs
```

### **STEP 4: Load Data**

#### **A. Load Data ke Tabel 1NF (CSV)**

**Cara 1: MySQL Workbench Table Data Import Wizard**
1. Klik kanan pada `tabel_krs_1nf` → Table Data Import Wizard
2. Browse file `data_1nf.csv`
3. Next → Map kolom sesuai header CSV
4. Execute Import

**Cara 2: Command Line (Windows)**
```sql
LOAD DATA LOCAL INFILE 'C:/Users/ASUS/Documents/SEMESTER 5/Basis Data Lanjut/TestingKRS/data_1nf.csv'
INTO TABLE tabel_krs_1nf
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(nim, nama_mhs, kode_mk, nama_mk, sks, nidn_dosen, nama_dosen, nohp_dosen);
```

**Jika error "local_infile disabled":**
```sql
-- Enable local infile terlebih dahulu
SET GLOBAL local_infile = 1;
-- Restart MySQL client dengan flag:
-- mysql --local-infile=1 -u root -p
```

#### **B. Load Data ke Tabel 3NF (SQL Dump)**

**Cara 1: MySQL Workbench**
1. File → Run SQL Script
2. Pilih file `data_3nf.sql`
3. Execute

**Cara 2: Command Line**
```bash
mysql -u root -p experiment_db < data_3nf.sql
```

**Cara 3: Di dalam MySQL CLI**
```sql
USE experiment_db;
SOURCE C:/Users/ASUS/Documents/SEMESTER 5/Basis Data Lanjut/TestingKRS/data_3nf.sql;
```

### **STEP 5: Verifikasi Data**

```sql
-- Cek jumlah data per tabel
SELECT 'Mahasiswa' AS tabel, COUNT(*) AS jumlah FROM mahasiswa
UNION ALL
SELECT 'Dosen', COUNT(*) FROM dosen
UNION ALL
SELECT 'Mata Kuliah', COUNT(*) FROM mata_kuliah
UNION ALL
SELECT 'KRS', COUNT(*) FROM krs
UNION ALL
SELECT 'Tabel 1NF', COUNT(*) FROM tabel_krs_1nf;
```

**Expected Output:**
```
+-------------+---------+
| tabel       | jumlah  |
+-------------+---------+
| Mahasiswa   | 1000    |
| Dosen       | 50      |
| Mata Kuliah | 100     |
| KRS         | 10000+  |
| Tabel 1NF   | 10000+  |
+-------------+---------+
```

### **STEP 6: Run Benchmark Tests**

1. Buka file `benchmark_queries.sql` di MySQL Workbench
2. Jalankan query satu per satu
3. Catat **Duration** di bagian bawah (Action Output)
4. Ulangi 3-5 kali untuk setiap query, ambil rata-rata

**Query yang Ditest:**
- ✅ **Kasus A:** Simple SELECT (cari KRS mahasiswa tertentu)
- ✅ **Kasus B:** Complex Aggregation (hitung total SKS per dosen)
- ✅ **Kasus C:** UPDATE (ganti nomor HP dosen)

### **STEP 7: Dokumentasi Hasil**

Buat tabel perbandingan seperti ini:

| **Kasus**            | **1NF (detik)** | **3NF (detik)** | **Pemenang** |
|----------------------|-----------------|-----------------|--------------|
| Simple SELECT        | 0.03            | 0.12            | 1NF          |
| Complex Aggregation  | 0.18            | 0.35            | 1NF          |
| UPDATE 1 Dosen       | 1.25            | 0.01            | 3NF (125x!)  |

---

## 📊 HASIL YANG DIHARAPKAN

### **Performa READ (SELECT):**
- 🏆 **1NF lebih cepat** (3-4x) karena tidak perlu JOIN
- Cocok untuk reporting/analytics yang simple

### **Performa WRITE (UPDATE/DELETE):**
- 🏆 **3NF jauh lebih cepat** (100x+) karena update hanya 1 row
- Cocok untuk sistem transaksional

### **Storage:**
- 🏆 **3NF lebih hemat** (60-70%) karena minimal duplikasi

### **Data Integrity:**
- 🏆 **3NF lebih aman** dengan Foreign Key Constraints

---

## 🎯 KESIMPULAN UNTUK SISTEM AKADEMIK

**Rekomendasi: Gunakan 3NF (Normalized)**

**Alasan:**
1. Sistem akademik adalah **transactional system** (banyak UPDATE)
2. Data integrity **sangat penting** (nilai mahasiswa, data dosen)
3. Relasi kompleks (mahasiswa ↔ MK ↔ dosen)
4. Data sering berubah (mahasiswa add/drop MK)

**Kapan pakai 1NF?**
- Jika build **reporting dashboard** (read-only)
- Data warehouse untuk historical analysis
- Data tidak pernah diupdate

---

## 🛠️ TROUBLESHOOTING

### **Problem: "Faker module not found"**
```bash
pip install faker
```

### **Problem: "MySQL ERROR 1290: Local infile disabled"**
```sql
SET GLOBAL local_infile = 1;
-- Restart MySQL client dengan flag --local-infile=1
```

### **Problem: "Foreign Key Constraint Fails"**
- Pastikan urutan import SQL dump benar:
  1. mahasiswa
  2. dosen
  3. mata_kuliah
  4. krs (terakhir)

### **Problem: "Query terlalu lambat"**
- Pastikan index sudah dibuat (lihat di schema SQL)
- Jalankan `ANALYZE TABLE nama_tabel;` untuk update statistics
- Clear query cache: `RESET QUERY CACHE;`

---

## 📚 REFERENSI

- **File Analisis:** `ANALISIS_DAN_PANDUAN.md`
- **Benchmark Queries:** `benchmark_queries.sql`
- MySQL Documentation: https://dev.mysql.com/doc/
- Database Normalization: https://en.wikipedia.org/wiki/Database_normalization

---

## 👨‍💻 AUTHOR

**Tugas Basis Data Lanjut**  
Semester 5 - 2025

---

## 📝 CHECKLIST PENGERJAAN

- [ ] Install Python & library `faker`
- [ ] Generate data dengan `generate_data.py`
- [ ] Create database di MySQL
- [ ] Import schema 1NF dan 3NF
- [ ] Load data CSV dan SQL dump
- [ ] Verifikasi jumlah data
- [ ] Run benchmark queries (3-5 kali per query)
- [ ] Dokumentasi hasil dalam tabel
- [ ] Analisis & kesimpulan
- [ ] Screenshot untuk laporan
- [ ] Presentasi hasil

---

**Good luck! 🚀**
