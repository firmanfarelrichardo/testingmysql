# PANDUAN LENGKAP: Experiment 1NF vs 3NF
## Analisis Normalisasi Database untuk Sistem Akademik

---

## 📋 DESKRIPSI PROJECT

Project ini membandingkan performa database dengan dua pendekatan berbeda:
- **1NF (First Normal Form)**: Struktur denormalized dengan satu tabel flat
- **3NF (Third Normal Form)**: Struktur normalized dengan relasi antar tabel

**Tujuan:** Memahami trade-off antara kecepatan query vs integritas data dalam sistem database.

---

## 📂 STRUKTUR FILE

```
TestingKRS/
├── generate_data.py          # Script generator data dummy
├── data_1nf.csv              # Data untuk tabel 1NF (flat)
├── data_3nf.sql              # Data untuk tabel 3NF (normalized)
├── schema_1nf.sql            # Schema database 1NF
├── schema_3nf.sql            # Schema database 3NF
├── setup_database.sql        # File utama untuk setup lengkap
├── testing.sql               # Query benchmark untuk testing
└── ANALISIS_DAN_PANDUAN.md   # File ini
```

---

## 🚀 CARA MENGGUNAKAN

### **1. Generate Data Dummy**
```bash
python generate_data.py
```
Output:
- `data_1nf.csv` (1000 mahasiswa × rata-rata 10 mata kuliah = ~10,000 baris)
- `data_3nf.sql` (INSERT statements untuk mahasiswa, dosen, mata kuliah, KRS)

### **2. Setup Database**
```bash
# Di MySQL Command Line / PowerShell
mysql -u root -p < setup_database.sql
```

Atau di MySQL Workbench:
1. File → Run SQL Script
2. Pilih `setup_database.sql`
3. Execute

### **3. Import Data 1NF**
Di MySQL Workbench:
1. Klik kanan `tabel_krs_1nf` → Table Data Import Wizard
2. Pilih file `data_1nf.csv`
3. Next → Next → Finish

### **4. Jalankan Testing**
```bash
mysql -u root -p experiment_db < testing.sql
```
Atau jalankan query satu per satu di Workbench dan catat hasilnya.

---

## 📊 ANALISIS PERFORMA

### **Skenario 1NF Lebih Cepat:**

**Simple SELECT Queries (Read-Heavy)**
- Semua data dalam 1 tabel → tidak perlu JOIN
- Ideal untuk: Data warehouse, reporting, analytics
- Contoh: `SELECT * FROM tabel_krs_1nf WHERE nama_mhs LIKE '%Budi%'`

### **Skenario 3NF Lebih Cepat:**

**UPDATE/DELETE Operations (Write-Heavy)**
- Update 1 row vs 1000+ rows
- Tidak ada risiko data inconsistency
- Ideal untuk: Transactional systems (OLTP)
- Contoh: Update nomor HP mahasiswa

**Data Integrity**
- Foreign Key mencegah orphan records
- Cascade rules otomatis menjaga konsistensi

**Storage Efficiency**
- Hemat 60-70% storage (minimal redundancy)

---

## 📈 HASIL BENCHMARK (Expected)

| **Metrik**               | **1NF**        | **3NF**        | **Pemenang** |
|--------------------------|----------------|----------------|--------------|
| Simple SELECT            | 0.03 detik     | 0.12 detik     | **1NF** (4x) |
| Complex Aggregation      | 0.18 detik     | 0.35 detik     | **1NF** (2x) |
| UPDATE 1 Record          | 1.50 detik     | 0.01 detik     | **3NF** (150x) |
| Storage Size (10k rows)  | 8.5 MB         | 3.2 MB         | **3NF** (62% hemat) |
| Data Consistency Risk    | **TINGGI** ⚠️  | **RENDAH** ✅  | **3NF** |

---

## 🎯 KESIMPULAN

### **Gunakan 1NF Jika:**
- Aplikasi read-heavy (90% SELECT, 10% UPDATE)
- Data bersifat immutable (log files, historical data)
- Butuh response time sangat cepat untuk simple queries
- Contoh: Data warehouse, OLAP, reporting dashboard

### **Gunakan 3NF Jika:**
- Aplikasi transactional (OLTP) dengan banyak INSERT/UPDATE/DELETE
- Data integrity adalah prioritas utama
- Data sering berubah dan perlu konsistensi
- Contoh: Sistem akademik, banking, e-commerce, CRM

### **Rekomendasi untuk Sistem Akademik:**
✅ **Pilih 3NF** karena:
- Data mahasiswa/dosen sering berubah (alamat, nomor HP, dll)
- Integritas data sangat penting (nilai, transkrip)
- Relasi antar entitas kompleks (mahasiswa-dosen-matakuliah)

---

## 💡 OPTIMASI LANJUTAN

**Jika 3NF Terlalu Lambat untuk READ:**

1. **Materialized View** - Buat view denormalized untuk query yang sering
2. **Indexing Strategy** - Tambahkan composite index
3. **Query Caching** - Gunakan Redis/Memcached

---

## 📚 REFERENSI

**First Normal Form (1NF):**
- Setiap kolom berisi atomic value
- Tidak ada repeating groups

**Third Normal Form (3NF):**
- Memenuhi 2NF (no partial dependency)
- No transitive dependency

**Denormalization:**
- Trade-off: Speed vs Integrity
- Butuh dokumentasi & maintenance ketat

---

**Good luck dengan tugas Basis Data Lanjut! 🎓**
