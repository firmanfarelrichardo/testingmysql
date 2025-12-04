# Experiment: Database 1NF vs 3NF
## Analisis Performa Normalisasi Database

---

## 📁 Struktur File

```
TestingKRS/
├── setup_database.sql        # ⭐ FILE UTAMA - Setup lengkap database
├── testing.sql               # Query benchmark untuk testing
├── drop_indexes.sql          # 🔧 Hapus semua index dari database
├── create_indexes.sql        # 🔧 Buat ulang semua index
├── ANALISIS_DAN_PANDUAN.md   # Dokumentasi lengkap & analisis
├── README.md                 # File ini - Quick start guide
├── generate_data.py          # Script generator data dummy
├── data_1nf.csv              # Data 1NF (backup)
├── data_3nf.sql              # Data 3NF (backup)
├── schema_1nf.sql            # Schema 1NF (backup)
└── schema_3nf.sql            # Schema 3NF (backup)
```

---

## 🚀 Quick Start

### **1. Setup Database (Satu Langkah!)**

**Via MySQL Command Line / PowerShell:**
```bash
mysql -u root -p < setup_database.sql
```

**Via MySQL Workbench:**
1. File → Run SQL Script
2. Pilih `setup_database.sql`
3. Klik Execute

### **2. Verifikasi**

Setelah import selesai, cek hasilnya:
```sql
USE experiment_db;

-- Cek jumlah data
SELECT 'Mahasiswa' AS tabel, COUNT(*) AS jumlah FROM mahasiswa
UNION ALL
SELECT 'Dosen', COUNT(*) FROM dosen
UNION ALL
SELECT 'Mata Kuliah', COUNT(*) FROM mata_kuliah
UNION ALL
SELECT 'KRS (3NF)', COUNT(*) FROM krs
UNION ALL
SELECT 'Tabel 1NF', COUNT(*) FROM tabel_krs_1nf;
```

**Output yang diharapkan:**
```
+----------------+--------+
| tabel          | jumlah |
+----------------+--------+
| Mahasiswa      |   1000 |
| Dosen          |     50 |
| Mata Kuliah    |    100 |
| KRS (3NF)      |  10000 |
| Tabel 1NF      |  10000 |
+----------------+--------+
```

### **3. Jalankan Benchmark Testing**

```bash
mysql -u root -p experiment_db < testing.sql
```

Atau buka `testing.sql` di MySQL Workbench dan jalankan query satu per satu.

---

## 📊 Isi Database

### **Tabel 1NF (Denormalized)**
- **1 tabel flat**: `tabel_krs_1nf`
- **10,000 baris** dengan duplikasi data
- Kolom: nim, nama_mhs, nohp_mhs, kode_mk, nama_mk, sks, nidn_dosen, nama_dosen

### **Tabel 3NF (Normalized)**
- **4 tabel dengan relasi:**
  - `mahasiswa` (1,000 records)
  - `dosen` (50 records)
  - `mata_kuliah` (100 records)
  - `krs` (10,000 records)
- Foreign Key constraints dengan CASCADE

---

## 🎯 Tujuan Experiment

Membandingkan performa antara:
- **1NF**: Cepat untuk READ, lambat untuk WRITE, risiko inkonsistensi tinggi
- **3NF**: Lambat untuk READ (perlu JOIN), cepat untuk WRITE, data integrity terjaga

**Hasil yang diharapkan:**
- 1NF lebih cepat untuk SELECT sederhana (2-4x)
- 3NF lebih cepat untuk UPDATE/DELETE (50-150x)
- 3NF hemat storage (60-70%)

---

## 🔧 Troubleshooting

**Error: "Access denied"**
```sql
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
```

**Error: "Foreign key constraint fails"**
- Pastikan urutan DROP table benar (child dulu, parent terakhir)
- File `setup_database.sql` sudah menghandle ini

**Error: "max_allowed_packet"**
```sql
SET GLOBAL max_allowed_packet=67108864; -- 64MB
```

**Ingin reset database:**
```bash
mysql -u root -p -e "DROP DATABASE IF EXISTS experiment_db;"
mysql -u root -p < setup_database.sql
```

---

## 🔧 Manajemen Index

### **Menghapus Semua Index**

Gunakan untuk testing performa tanpa index:
```bash
mysql -u root -p experiment_db < drop_indexes.sql
```

Atau di MySQL Workbench: File → Run SQL Script → `drop_indexes.sql`

**Yang dihapus:**
- ✅ Index optimasi query (idx_nim, idx_kode_mk, idx_nama, dll)

**Yang TIDAK dihapus:**
- ❌ Primary Key
- ❌ Foreign Key constraints
- ❌ Unique constraints

### **Membuat Ulang Index**

Setelah testing tanpa index, buat kembali index:
```bash
mysql -u root -p experiment_db < create_indexes.sql
```

**Use Case:**
- Bandingkan kecepatan query TANPA index vs DENGAN index
- Testing impact indexing pada performa
- Demonstrasi pentingnya index untuk query optimization

---

## 📖 Dokumentasi Lengkap

Baca file `ANALISIS_DAN_PANDUAN.md` untuk:
- Analisis mendalam 1NF vs 3NF
- Use case di dunia nyata
- Tips optimasi
- Interpretasi hasil benchmark

---

## 👨‍💻 Author

Dibuat untuk tugas Basis Data Lanjut - Experiment Normalisasi Database

---

**Good luck! 🎓**
