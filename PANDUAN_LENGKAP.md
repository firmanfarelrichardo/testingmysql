# 🎯 PANDUAN LENGKAP: EXPERIMENT DATABASE 1NF VS 3NF

## 📋 DAFTAR ISI
1. [Persiapan](#persiapan)
2. [Generate Data](#generate-data)
3. [Setup Database](#setup-database)
4. [Import Data](#import-data)
5. [Verifikasi](#verifikasi)
6. [Benchmark Testing](#benchmark-testing)
7. [Dokumentasi Hasil](#dokumentasi-hasil)

---

## 📦 PERSIAPAN

### ✅ Persyaratan Sistem:
- **Python 3.x** terinstall
- **MySQL/MariaDB** terinstall
- **MySQL Workbench** (opsional, untuk GUI)

### 📥 Install Dependencies

Buka PowerShell di folder project ini:

```powershell
cd "C:\Users\ASUS\Documents\SEMESTER 5\Basis Data Lanjut\TestingKRS"
pip install faker
```

---

## 🔧 GENERATE DATA

### Jalankan Script Generator:

```powershell
python generate_data.py
```

### ✅ Output yang Dihasilkan:

1. **data_1nf.csv** (10,000+ baris)
   - Format CSV untuk tabel denormalized
   - Kolom: nim, nama_mhs, kode_mk, nama_mk, sks, nidn_dosen, nama_dosen, **nohp_mhs**

2. **data_3nf.sql** (11,150+ INSERT statements)
   - SQL dump untuk 4 tabel normalized
   - Mahasiswa (1,000 rows dengan **nohp_mhs**)
   - Dosen (50 rows **tanpa no_hp**)
   - Mata Kuliah (100 rows)
   - KRS (10,000+ rows)

### 📊 Spesifikasi Data:
- ✅ 1,000 Mahasiswa dengan nomor HP format Indonesia (08xx-xxxx-xxxx)
- ✅ 50 Dosen (TANPA nomor HP)
- ✅ 100 Mata Kuliah (nama realistis tanpa nomor)
- ✅ 10,000+ Transaksi KRS (unique combinations)

---

## 🗄️ SETUP DATABASE

### LANGKAH 1: Buat Database Baru

Buka MySQL Workbench atau MySQL CLI, lalu jalankan:

```sql
CREATE DATABASE experiment_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE experiment_db;
```

### LANGKAH 2: Import Schema 1NF

**Cara A: MySQL Workbench**
1. File → Open SQL Script
2. Pilih file: `schema_1nf.sql`
3. Klik Execute (⚡)

**Cara B: MySQL CLI**
```sql
USE experiment_db;
SOURCE C:/Users/ASUS/Documents/SEMESTER 5/Basis Data Lanjut/TestingKRS/schema_1nf.sql;
```

**Cara C: PowerShell**
```powershell
Get-Content "schema_1nf.sql" | mysql -u root -p experiment_db
```

### LANGKAH 3: Import Schema 3NF

**Cara A: MySQL Workbench**
1. File → Open SQL Script
2. Pilih file: `schema_3nf.sql`
3. Klik Execute (⚡)

**Cara B: MySQL CLI**
```sql
USE experiment_db;
SOURCE C:/Users/ASUS/Documents/SEMESTER 5/Basis Data Lanjut/TestingKRS/schema_3nf.sql;
```

**Cara C: PowerShell**
```powershell
Get-Content "schema_3nf.sql" | mysql -u root -p experiment_db
```

### LANGKAH 4: Verifikasi Tabel Terbuat

```sql
SHOW TABLES;
```

**Expected Output:**
```
+-------------------------+
| Tables_in_experiment_db |
+-------------------------+
| dosen                   |
| krs                     |
| mahasiswa               |
| mata_kuliah             |
| tabel_krs_1nf           |
+-------------------------+
5 rows in set
```

### Cek Struktur Tabel Mahasiswa (harus ada nohp_mhs):

```sql
DESC mahasiswa;
```

**Expected:**
```
+--------------+--------------+------+-----+---------+-------+
| Field        | Type         | Null | Key | Default | Extra |
+--------------+--------------+------+-----+---------+-------+
| nim          | varchar(20)  | NO   | PRI | NULL    |       |
| nama_lengkap | varchar(100) | NO   | MUL | NULL    |       |
| nohp_mhs     | varchar(20)  | NO   |     | NULL    |       |
+--------------+--------------+------+-----+---------+-------+
```

### Cek Struktur Tabel Dosen (TIDAK ada no_hp):

```sql
DESC dosen;
```

**Expected:**
```
+--------------+--------------+------+-----+---------+-------+
| Field        | Type         | Null | Key | Default | Extra |
+--------------+--------------+------+-----+---------+-------+
| nidn         | varchar(20)  | NO   | PRI | NULL    |       |
| nama_lengkap | varchar(100) | NO   | MUL | NULL    |       |
+--------------+--------------+------+-----+---------+-------+
```

---

## 📥 IMPORT DATA

### LANGKAH 5: Load Data ke 3NF (SQL Dump)

**Cara A: MySQL Workbench (Recommended)**
1. File → Run SQL Script
2. Pilih file: `data_3nf.sql`
3. Klik Start
4. Tunggu sampai selesai (~30 detik)

**Cara B: MySQL CLI**
```sql
USE experiment_db;
SOURCE C:/Users/ASUS/Documents/SEMESTER 5/Basis Data Lanjut/TestingKRS/data_3nf.sql;
```

**Cara C: PowerShell**
```powershell
Get-Content "data_3nf.sql" | mysql -u root -p experiment_db
```

### LANGKAH 6: Load Data ke 1NF (CSV Import)

**Cara A: MySQL Workbench Table Data Import Wizard (RECOMMENDED)**

1. Di panel kiri, expand `experiment_db`
2. Klik kanan pada tabel `tabel_krs_1nf`
3. Pilih **Table Data Import Wizard**
4. Browse dan pilih file: `data_1nf.csv`
5. Klik **Next**
6. **PENTING**: Pastikan mapping kolom benar:
   ```
   CSV Column        → Table Column
   ─────────────────────────────────
   nim              → nim
   nama_mhs         → nama_mhs
   kode_mk          → kode_mk
   nama_mk          → nama_mk
   sks              → sks
   nidn_dosen       → nidn_dosen
   nama_dosen       → nama_dosen
   nohp_mhs         → nohp_mhs
   ```
7. Klik **Next** → **Next** → **Finish**
8. Tunggu sampai import selesai

**Cara B: MySQL CLI (Jika local_infile enabled)**

```sql
-- 1. Enable local_infile terlebih dahulu
SET GLOBAL local_infile = 1;
```

Keluar dari MySQL, lalu login kembali dengan flag:

```powershell
mysql --local-infile=1 -u root -p
```

Kemudian jalankan:

```sql
USE experiment_db;

LOAD DATA LOCAL INFILE 'C:/Users/ASUS/Documents/SEMESTER 5/Basis Data Lanjut/TestingKRS/data_1nf.csv'
INTO TABLE tabel_krs_1nf
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(nim, nama_mhs, kode_mk, nama_mk, sks, nidn_dosen, nama_dosen, nohp_mhs);
```

**Jika Error "The MySQL server is running with the --secure-file-priv option":**

Gunakan Cara A (Import Wizard) atau copy file CSV ke folder secure-file-priv.

---

## ✅ VERIFIKASI

### Cek Jumlah Data Per Tabel:

```sql
SELECT 
    'Mahasiswa' AS tabel, COUNT(*) AS jumlah FROM mahasiswa
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
+--------------+--------+
| tabel        | jumlah |
+--------------+--------+
| Mahasiswa    |   1000 |
| Dosen        |     50 |
| Mata Kuliah  |    100 |
| KRS          |  10000 |
| Tabel 1NF    |  10000 |
+--------------+--------+
```

### Verifikasi Mahasiswa Punya nohp_mhs:

```sql
SELECT nim, nama_lengkap, nohp_mhs FROM mahasiswa LIMIT 5;
```

**Expected:**
```
+------------+------------------+----------------+
| nim        | nama_lengkap     | nohp_mhs       |
+------------+------------------+----------------+
| 2020000001 | Budi Santoso     | 0811-2345-6789 |
| 2020000002 | Siti Nurhaliza   | 0821-9876-5432 |
| ...        | ...              | ...            |
+------------+------------------+----------------+
```

### Verifikasi Dosen TIDAK Punya no_hp:

```sql
SELECT * FROM dosen LIMIT 5;
```

**Expected (HANYA 2 kolom):**
```
+------------+------------------+
| nidn       | nama_lengkap     |
+------------+------------------+
| 0100000001 | Ahmad Fauzi      |
| 0100000002 | Dewi Lestari     |
| ...        | ...              |
+------------+------------------+
```

### Verifikasi Data 1NF Punya nohp_mhs:

```sql
SELECT nim, nama_mhs, nohp_mhs FROM tabel_krs_1nf LIMIT 5;
```

---

## 🏃 BENCHMARK TESTING

### PERSIAPAN: Reset Query Cache

**Jalankan sebelum SETIAP test:**

```sql
RESET QUERY CACHE;
```

### 🧪 KASUS A: Simple SELECT (Cari KRS Mahasiswa)

**Test 1NF:**
```sql
SELECT SQL_NO_CACHE 
    nama_mhs, nim, kode_mk, nama_mk, sks, nama_dosen
FROM tabel_krs_1nf
WHERE nama_mhs LIKE '%Siti%'
ORDER BY kode_mk;
```

**Test 3NF:**
```sql
SELECT SQL_NO_CACHE 
    m.nama_lengkap, m.nim, mk.kode_mk, mk.nama_mk, mk.sks, d.nama_lengkap AS nama_dosen
FROM mahasiswa m
INNER JOIN krs k ON m.nim = k.nim
INNER JOIN mata_kuliah mk ON k.kode_mk = mk.kode_mk
INNER JOIN dosen d ON mk.nidn_dosen = d.nidn
WHERE m.nama_lengkap LIKE '%Siti%'
ORDER BY mk.kode_mk;
```

📝 **Catat Duration** (lihat di bawah result grid MySQL Workbench)

**Ulangi 3-5 kali, ambil rata-rata!**

---

### 🧪 KASUS B: Complex Aggregation (Total SKS per Dosen)

**Test 1NF:**
```sql
SELECT SQL_NO_CACHE 
    nidn_dosen, nama_dosen,
    SUM(DISTINCT sks) AS total_sks_diajar,
    COUNT(DISTINCT nim) AS jumlah_mahasiswa
FROM tabel_krs_1nf
GROUP BY nidn_dosen, nama_dosen
ORDER BY total_sks_diajar DESC
LIMIT 20;
```

**Test 3NF:**
```sql
SELECT SQL_NO_CACHE 
    d.nidn, d.nama_lengkap AS nama_dosen,
    SUM(DISTINCT mk.sks) AS total_sks_diajar,
    COUNT(DISTINCT k.nim) AS jumlah_mahasiswa
FROM dosen d
INNER JOIN mata_kuliah mk ON d.nidn = mk.nidn_dosen
INNER JOIN krs k ON mk.kode_mk = k.kode_mk
GROUP BY d.nidn, d.nama_lengkap
ORDER BY total_sks_diajar DESC
LIMIT 20;
```

📝 **Catat Duration**

---

### 🧪 KASUS C: UPDATE (Update Anomaly Test)

**STEP 1: Cari Mahasiswa Bernama "Siti"**

1NF:
```sql
SELECT DISTINCT nim, nama_mhs 
FROM tabel_krs_1nf 
WHERE nama_mhs LIKE '%Siti%' 
LIMIT 1;
```

3NF:
```sql
SELECT nim, nama_lengkap 
FROM mahasiswa 
WHERE nama_lengkap LIKE '%Siti%' 
LIMIT 1;
```

**Catat NIM yang didapat** (misalnya: 202000123)

**STEP 2: UPDATE Nomor HP**

**Test 1NF (Update BANYAK Row):**
```sql
RESET QUERY CACHE;

UPDATE tabel_krs_1nf
SET nohp_mhs = '0811-9999-8888'
WHERE nim = '202000123';

SELECT ROW_COUNT();  -- Cek berapa row ter-update (hasilnya: banyak!)
```

📝 **Catat Duration dan Row Count**

**Test 3NF (Update 1 Row):**
```sql
RESET QUERY CACHE;

UPDATE mahasiswa
SET nohp_mhs = '0811-9999-8888'
WHERE nim = '202000123';

SELECT ROW_COUNT();  -- Hasilnya: 1
```

📝 **Catat Duration (harusnya SANGAT cepat!)**

---

## 📊 DOKUMENTASI HASIL

### Buat Tabel Perbandingan:

```
╔═══════════════════════════╦═══════════════╦═══════════════╦══════════════╗
║ Kasus                     ║ 1NF (detik)   ║ 3NF (detik)   ║ Pemenang     ║
╠═══════════════════════════╬═══════════════╬═══════════════╬══════════════╣
║ Simple SELECT             ║ 0.035         ║ 0.142         ║ 1NF (4x)     ║
║ Complex Aggregation       ║ 0.187         ║ 0.356         ║ 1NF (2x)     ║
║ UPDATE Mahasiswa          ║ 1.520         ║ 0.012         ║ 3NF (126x!)  ║
╚═══════════════════════════╩═══════════════╩═══════════════╩══════════════╝
```

### Cek Ukuran Storage:

```sql
SELECT 
    table_name AS 'Nama Tabel',
    ROUND((data_length + index_length) / 1024 / 1024, 2) AS 'Ukuran (MB)',
    table_rows AS 'Jumlah Baris'
FROM information_schema.TABLES
WHERE table_schema = 'experiment_db'
    AND table_name IN ('tabel_krs_1nf', 'mahasiswa', 'dosen', 'mata_kuliah', 'krs')
ORDER BY (data_length + index_length) DESC;
```

**Expected:**
```
+---------------+-------------+--------------+
| Nama Tabel    | Ukuran (MB) | Jumlah Baris |
+---------------+-------------+--------------+
| tabel_krs_1nf |        8.52 |        10000 |
| krs           |        1.52 |        10000 |
| mahasiswa     |        0.16 |         1000 |
| mata_kuliah   |        0.02 |          100 |
| dosen         |        0.02 |           50 |
+---------------+-------------+--------------+
```

**Analisis:**
- 1NF: 8.52 MB
- 3NF Total: 1.52 + 0.16 + 0.02 + 0.02 = 1.72 MB
- **Penghematan: 79.8%**

---

## 🎯 KESIMPULAN EXPECTED

### ✅ Performa READ:
- **1NF lebih cepat 3-4x** untuk Simple SELECT (no JOIN)
- **1NF lebih cepat 2x** untuk Aggregation

### ✅ Performa WRITE:
- **3NF lebih cepat 100x+** untuk UPDATE
- **3NF update 1 row**, 1NF update puluhan row

### ✅ Storage:
- **3NF lebih hemat 60-80%**

### ✅ Data Integrity:
- **3NF lebih aman** (Foreign Key Constraints)
- **1NF risiko inconsistency** tinggi

---

## 🔧 TROUBLESHOOTING

### Error: "Column 'nohp_mhs' not found"
**Solusi:** Pastikan sudah generate ulang data dengan `python generate_data.py`

### Error: "Unknown column 'no_hp' in dosen"
**Solusi:** Tabel dosen TIDAK memiliki kolom no_hp lagi, cek schema_3nf.sql

### Error: "Duplicate entry for key 'krs.unique_krs'"
**Solusi:** Truncate tabel dulu:
```sql
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE krs;
TRUNCATE TABLE tabel_krs_1nf;
SET FOREIGN_KEY_CHECKS = 1;
```

### Import CSV Gagal di MySQL CLI
**Solusi:** Gunakan MySQL Workbench Table Data Import Wizard (lebih mudah dan aman)

---

## 📚 REFERENSI FILE

- `generate_data.py` - Script generator data
- `schema_1nf.sql` - DDL tabel denormalized
- `schema_3nf.sql` - DDL tabel normalized
- `benchmark_queries.sql` - Query testing lengkap
- `README.md` - Overview project
- `CHEAT_SHEET.md` - Command cepat
- `KONSEP_TEORI.md` - Teori normalisasi
- `ANALISIS_DAN_PANDUAN.md` - Analisis profesional

---

## 🎉 SELESAI!

Semua langkah sudah selesai! Database experiment siap untuk:
- ✅ Benchmark testing
- ✅ Analisis performa
- ✅ Presentasi/laporan tugas
- ✅ Pemahaman konsep normalisasi

**Struktur Final Database:**
- Mahasiswa: Memiliki **nohp_mhs** (format Indonesia)
- Dosen: **TIDAK** memiliki nomor HP
- Mata Kuliah: Nama **tanpa nomor**
- KRS: Relasi mahasiswa ↔ mata kuliah
- Tabel 1NF: Flat table dengan **nohp_mhs**

**Good Luck! 🚀**
