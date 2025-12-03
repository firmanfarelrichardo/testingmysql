# 🚀 CHEAT SHEET - COMMAND CEPAT

## 📦 SETUP ENVIRONMENT

```bash
# Install dependencies
pip install -r requirements.txt

# Atau manual
pip install faker
```

---

## 🔧 GENERATE DATA

```bash
# Generate 10,000+ data dummy
python generate_data.py
```

**Output:**
- `data_1nf.csv` → untuk tabel flat
- `data_3nf.sql` → untuk tabel normalized

---

## 🗄️ SETUP DATABASE (MySQL CLI)

```sql
-- 1. Buat database
CREATE DATABASE experiment_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE experiment_db;

-- 2. Import schema 1NF
SOURCE schema_1nf.sql;

-- 3. Import schema 3NF
SOURCE schema_3nf.sql;

-- 4. Verify tables
SHOW TABLES;
-- Output: tabel_krs_1nf, mahasiswa, dosen, mata_kuliah, krs
```

---

## 📥 LOAD DATA

### **Method A: Import SQL Dump (3NF)**

```sql
USE experiment_db;
SOURCE data_3nf.sql;
```

### **Method B: Import CSV (1NF) - Workbench**

1. Right-click `tabel_krs_1nf` → **Table Data Import Wizard**
2. Select `data_1nf.csv`
3. Map columns → Execute

### **Method C: Import CSV (1NF) - CLI**

```sql
-- Windows path example
LOAD DATA LOCAL INFILE 'C:/Users/ASUS/Documents/SEMESTER 5/Basis Data Lanjut/TestingKRS/data_1nf.csv'
INTO TABLE tabel_krs_1nf
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

**Jika error "local_infile disabled":**
```sql
SET GLOBAL local_infile = 1;
```

Lalu restart MySQL client dengan:
```bash
mysql --local-infile=1 -u root -p
```

---

## ✅ VERIFY DATA

```sql
-- Quick count check
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

**Expected:**
- Mahasiswa: 1,000
- Dosen: 50
- Mata Kuliah: 100
- KRS: 10,000+
- Tabel 1NF: 10,000+

---

## 🏃 BENCHMARK QUERIES (Copy-Paste Ready)

### **PERSIAPAN**
```sql
RESET QUERY CACHE;  -- Jalankan sebelum setiap test
```

### **KASUS A: Simple SELECT (Cari KRS mahasiswa "Budi")**

**1NF:**
```sql
SELECT SQL_NO_CACHE 
    nama_mhs, nim, kode_mk, nama_mk, sks, nama_dosen
FROM tabel_krs_1nf
WHERE nama_mhs LIKE '%Budi%'
ORDER BY kode_mk;
```

**3NF:**
```sql
SELECT SQL_NO_CACHE 
    m.nama_lengkap, m.nim, mk.kode_mk, mk.nama_mk, mk.sks, d.nama_lengkap AS nama_dosen
FROM mahasiswa m
INNER JOIN krs k ON m.nim = k.nim
INNER JOIN mata_kuliah mk ON k.kode_mk = mk.kode_mk
INNER JOIN dosen d ON mk.nidn_dosen = d.nidn
WHERE m.nama_lengkap LIKE '%Budi%'
ORDER BY mk.kode_mk;
```

### **KASUS B: Complex Aggregation (Total SKS per Dosen)**

**1NF:**
```sql
SELECT SQL_NO_CACHE 
    nidn_dosen, nama_dosen,
    SUM(sks) AS total_sks_diajar,
    COUNT(DISTINCT nim) AS jumlah_mahasiswa
FROM tabel_krs_1nf
GROUP BY nidn_dosen, nama_dosen
ORDER BY total_sks_diajar DESC
LIMIT 20;
```

**3NF:**
```sql
SELECT SQL_NO_CACHE 
    d.nidn, d.nama_lengkap AS nama_dosen,
    SUM(mk.sks) AS total_sks_diajar,
    COUNT(DISTINCT k.nim) AS jumlah_mahasiswa
FROM dosen d
INNER JOIN mata_kuliah mk ON d.nidn = mk.nidn_dosen
INNER JOIN krs k ON mk.kode_mk = k.kode_mk
GROUP BY d.nidn, d.nama_lengkap
ORDER BY total_sks_diajar DESC
LIMIT 20;
```

### **KASUS C: UPDATE (Ganti No HP Dosen)**

**Step 1: Cari dosen terlebih dahulu**
```sql
-- 1NF
SELECT DISTINCT nidn_dosen, nama_dosen 
FROM tabel_krs_1nf 
WHERE nama_dosen LIKE '%Siti%' 
LIMIT 1;

-- 3NF
SELECT nidn, nama_lengkap 
FROM dosen 
WHERE nama_lengkap LIKE '%Siti%' 
LIMIT 1;
```

**Step 2: UPDATE (ganti '0123456789' dengan NIDN yang didapat)**

**1NF (UPDATE BANYAK ROW):**
```sql
UPDATE tabel_krs_1nf
SET nohp_dosen = '081234567890'
WHERE nidn_dosen = '0123456789';

-- Cek jumlah row yang ter-update
SELECT ROW_COUNT();
```

**3NF (UPDATE 1 ROW):**
```sql
UPDATE dosen
SET no_hp = '081234567890'
WHERE nidn = '0123456789';

-- Cek jumlah row yang ter-update
SELECT ROW_COUNT();  -- Hasilnya: 1
```

---

## 📊 CEK UKURAN STORAGE

```sql
SELECT 
    table_name AS 'Nama Tabel',
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Ukuran (MB)',
    table_rows AS 'Jumlah Baris'
FROM information_schema.TABLES
WHERE table_schema = 'experiment_db'
    AND table_name IN ('tabel_krs_1nf', 'mahasiswa', 'dosen', 'mata_kuliah', 'krs')
ORDER BY (data_length + index_length) DESC;
```

**Expected:**
- `tabel_krs_1nf`: ~5-10 MB
- `krs`: ~1-2 MB
- `mahasiswa`, `dosen`, `mata_kuliah`: < 1 MB each

---

## 🔍 ANALISIS QUERY PLAN (EXPLAIN)

```sql
-- Lihat bagaimana MySQL execute query
EXPLAIN SELECT SQL_NO_CACHE ...

-- Kolom penting:
-- type: const > eq_ref > ref > range > index > ALL
-- rows: semakin kecil semakin bagus
-- Extra: "Using index" = bagus, "Using filesort" = lambat
```

---

## 📝 TEMPLATE DOKUMENTASI HASIL

```
+------------------------+----------------+----------------+------------+
| Kasus                  | 1NF (detik)    | 3NF (detik)    | Pemenang   |
+------------------------+----------------+----------------+------------+
| Simple SELECT          | 0.03           | 0.12           | 1NF (4x)   |
| Complex Aggregation    | 0.18           | 0.35           | 1NF (2x)   |
| UPDATE 1 Dosen         | 1.25           | 0.01           | 3NF (125x) |
+------------------------+----------------+----------------+------------+

UKURAN STORAGE:
- 1NF: 8.5 MB
- 3NF (Total): 3.2 MB
- Penghematan: 62%

KESIMPULAN:
✅ 1NF lebih cepat untuk READ sederhana (no JOIN)
✅ 3NF jauh lebih cepat untuk WRITE (update 1 row vs ribuan)
✅ 3NF lebih aman (Foreign Key Constraints)
✅ 3NF lebih hemat storage (minimal duplikasi)

REKOMENDASI: Gunakan 3NF untuk sistem akademik
```

---

## 🐛 COMMON ISSUES

### **Error: "Table doesn't exist"**
```sql
-- Pastikan sudah create schema
USE experiment_db;
SOURCE schema_1nf.sql;
SOURCE schema_3nf.sql;
```

### **Error: "Duplicate entry"**
```sql
-- Hapus data lama terlebih dahulu
TRUNCATE TABLE krs;
TRUNCATE TABLE mata_kuliah;
TRUNCATE TABLE dosen;
TRUNCATE TABLE mahasiswa;
TRUNCATE TABLE tabel_krs_1nf;
```

### **Error: "Foreign key constraint fails"**
```sql
-- Import harus urut: dosen → mata_kuliah → mahasiswa → krs
-- Jangan skip atau acak urutannya!
```

### **Query terlalu lambat**
```sql
-- Update statistics
ANALYZE TABLE tabel_krs_1nf;
ANALYZE TABLE mahasiswa;
ANALYZE TABLE dosen;
ANALYZE TABLE mata_kuliah;
ANALYZE TABLE krs;

-- Clear cache
RESET QUERY CACHE;
```

---

## 🎯 QUICK WIN TIPS

1. **Jalankan query 3-5 kali** → ambil rata-rata duration
2. **Screenshot hasil** → untuk laporan
3. **Catat "Rows examined"** dari EXPLAIN → untuk analisis
4. **Test di waktu berbeda** → morning vs evening (server load)
5. **Dokumentasi lengkap** → tulis setiap langkah

---

**Happy Testing! 🚀**
