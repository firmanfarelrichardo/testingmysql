# ANALISIS PROFESIONAL: 1NF vs 3NF
## Perbandingan Performa & Use Case

---

## 📊 HIPOTESIS PERFORMA

### **Skenario 1NF Menang (Denormalized)**

#### 1. **Simple SELECT Queries (Read-Heavy)**
**Mengapa?**
- Semua data sudah ada dalam 1 tabel → tidak perlu JOIN
- Index langsung mengarah ke data yang dibutuhkan
- CPU overhead minimal (no join processing)
- Cocok untuk analytical queries yang sederhana

**Contoh Kasus:**
```sql
-- Cepat di 1NF, lambat di 3NF
SELECT * FROM tabel_krs_1nf WHERE nama_mhs = 'Budi';
```

**Use Case di Dunia Nyata:**
- **Data Warehouse / OLAP Systems**
  - Reporting dashboard yang menampilkan data agregat
  - Business Intelligence tools (Tableau, Power BI)
  - Historical data yang jarang diupdate
  
- **High-Traffic Read Applications**
  - News website (artikel + author info dalam 1 tabel)
  - E-commerce product listings (product + seller info digabung)
  - Social media feeds (post + user info denormalized)

#### 2. **Data yang Jarang/Tidak Pernah Diupdate**
**Mengapa?**
- Jika data statis, masalah update anomaly tidak relevan
- Trade-off: Storage vs Speed → pilih speed

**Contoh Kasus:**
- Log files (write once, read many)
- Historical records (immutable data)
- Archived transactions

---

### **Skenario 3NF Menang (Normalized)**

#### 1. **UPDATE/DELETE Operations (Write-Heavy)**
**Mengapa?**
- Update hanya 1 row di tabel master, bukan ribuan row
- Tidak ada risiko data inconsistency
- Atomicity terjaga (all or nothing)

**Contoh Kasus:**
```sql
-- 1NF: Update 1000+ rows → LAMBAT + RISIKO
UPDATE tabel_krs_1nf SET nohp_dosen = '...' WHERE nidn_dosen = 'X';

-- 3NF: Update 1 row → CEPAT + AMAN
UPDATE dosen SET no_hp = '...' WHERE nidn = 'X';
```

**Perbandingan Waktu (Estimasi):**
- 1NF: 1-3 detik (untuk 1000 row)
- 3NF: 0.01 detik (untuk 1 row)
- **Speedup: 100-300x lebih cepat!**

#### 2. **Data Integrity (Integritas Data)**
**Mengapa?**
- Foreign Key Constraints mencegah orphan records
- Cascade rules menjaga konsistensi relasi
- Impossible untuk insert invalid data

**Contoh Masalah di 1NF:**
```
Row 1: nim=123, nama_mhs="Budi", nohp_dosen="08111"
Row 2: nim=123, nama_mhs="Budi", nohp_dosen="08222"  ← INKONSISTEN!
```

**Solusi di 3NF:**
- Tabel mahasiswa menyimpan data 1x (single source of truth)
- Tabel KRS hanya menyimpan foreign key (nim)
- Impossible untuk memiliki 2 versi data berbeda untuk NIM yang sama

#### 3. **Storage Efficiency**
**Mengapa?**
- Minimal redundancy → ukuran database lebih kecil
- Index lebih kecil → query optimizer lebih efisien
- Backup/restore lebih cepat

**Estimasi Ukuran (10,000 records):**
- 1NF: ~8-10 MB (semua kolom duplikat)
- 3NF: ~3-4 MB (data master hanya 1x)
- **Penghematan: 60-70% storage**

#### 4. **Complex Joins & Relationships**
**Mengapa?**
- Relasi antar entitas sudah didefinisikan secara eksplisit
- Query optimizer bisa membuat execution plan yang lebih baik
- Mudah untuk menambahkan tabel baru (extensible)

**Contoh Kasus:**
```sql
-- Query: "Cari semua dosen yang mengajar mahasiswa dari angkatan 2023"
-- Di 3NF: Mudah dengan JOIN
-- Di 1NF: Harus DISTINCT + subquery (rumit & lambat)
```

---

## 🎯 KESIMPULAN: KAPAN PAKAI YANG MANA?

### **Gunakan 1NF (Denormalized) Jika:**

✅ Aplikasi **read-heavy** (90% SELECT, 10% UPDATE)  
✅ Data bersifat **immutable** (tidak pernah diupdate)  
✅ Butuh **response time** yang sangat cepat untuk simple queries  
✅ Tidak masalah dengan **ukuran storage** yang besar  
✅ Data warehouse / OLAP / Reporting systems  

**Contoh Implementasi:**
- Google Analytics dashboard
- Server log aggregation
- E-commerce product search (dengan caching)
- Historical data archives

---

### **Gunakan 3NF (Normalized) Jika:**

✅ Aplikasi **transactional** (OLTP) dengan banyak INSERT/UPDATE/DELETE  
✅ **Data integrity** adalah prioritas utama  
✅ Butuh **flexibility** untuk relasi yang kompleks  
✅ **Storage efficiency** penting (biaya cloud storage)  
✅ Data sering berubah dan perlu konsistensi  

**Contoh Implementasi:**
- University academic system (seperti tugas ini!)
- Banking applications
- E-commerce order management
- CRM systems
- Inventory management

---

## 📈 HASIL BENCHMARK (Prediksi)

| **Metrik**               | **1NF**        | **3NF**        | **Pemenang** |
|--------------------------|----------------|----------------|--------------|
| Simple SELECT            | 0.03 detik     | 0.12 detik     | **1NF** (4x) |
| Complex Aggregation      | 0.18 detik     | 0.35 detik     | **1NF** (2x) |
| UPDATE 1 Master Record   | 1.50 detik     | 0.01 detik     | **3NF** (150x) |
| Storage Size (10k rows)  | 8.5 MB         | 3.2 MB         | **3NF** (62% hemat) |
| Data Consistency Risk    | **TINGGI** ⚠️  | **RENDAH** ✅  | **3NF** |
| Maintenance Complexity   | **TINGGI** 🔧  | **RENDAH** ✅  | **3NF** |

---

## 🔬 CARA VALIDASI HASIL EXPERIMENT

### **Step 1: Generate Data**
```bash
python generate_data.py
```
Output: `data_1nf.csv` dan `data_3nf.sql`

### **Step 2: Setup Database**
```sql
-- Buat database
CREATE DATABASE experiment_db;
USE experiment_db;

-- Import schema 1NF
SOURCE schema_1nf.sql;

-- Import schema 3NF
SOURCE schema_3nf.sql;

-- Load data 1NF (via MySQL Workbench Import Wizard)
-- atau gunakan LOAD DATA INFILE

-- Load data 3NF
SOURCE data_3nf.sql;
```

### **Step 3: Run Benchmark**
```sql
-- Copy-paste query dari benchmark_queries.sql
-- Catat Duration untuk setiap query
-- Ulangi 3-5 kali untuk rata-rata
```

### **Step 4: Analisis**
- Bandingkan waktu eksekusi
- Bandingkan ukuran storage
- Test update anomaly dengan skenario real

---

## 💡 TIPS UNTUK PRESENTASI TUGAS

### **Struktur Laporan yang Baik:**

1. **Pendahuluan**
   - Latar belakang (normalisasi di database)
   - Tujuan experiment (membuktikan trade-off)

2. **Metodologi**
   - Tools yang digunakan (Python, MySQL)
   - Spesifikasi data (1000 mhs, 50 dosen, dst)
   - Kasus pengujian (3 skenario query)

3. **Hasil Experiment**
   - Tabel perbandingan waktu eksekusi
   - Screenshot dari MySQL Workbench
   - Grafik (opsional, tapi bagus!)

4. **Analisis**
   - Interpretasi hasil (mengapa 1NF lebih cepat di SELECT?)
   - Diskusi trade-off (speed vs integrity)
   - Real-world use cases

5. **Kesimpulan**
   - Jawaban atas pertanyaan: "Kapan pakai 1NF vs 3NF?"
   - Rekomendasi untuk sistem akademik (pilih 3NF)

---

## 🚀 BONUS: OPTIMASI LANJUTAN

### **Jika 3NF Terlalu Lambat untuk READ:**

**Solusi 1: Materialized View**
```sql
-- Buat view yang denormalized tapi auto-update
CREATE VIEW view_krs_denormalized AS
SELECT m.nim, m.nama_lengkap, mk.nama_mk, d.nama_lengkap AS dosen
FROM krs k
JOIN mahasiswa m ON k.nim = m.nim
JOIN mata_kuliah mk ON k.kode_mk = mk.kode_mk
JOIN dosen d ON mk.nidn_dosen = d.nidn;

-- Query dari view (cepat seperti 1NF!)
SELECT * FROM view_krs_denormalized WHERE nama_lengkap = 'Budi';
```

**Solusi 2: Indexing Strategy**
```sql
-- Tambahkan composite index untuk query yang sering
CREATE INDEX idx_composite ON krs(nim, kode_mk);
```

**Solusi 3: Query Caching**
- Gunakan Redis/Memcached untuk cache hasil query
- Invalidate cache saat ada UPDATE

---

## 📚 REFERENSI TEORI

**First Normal Form (1NF):**
- Setiap kolom hanya berisi atomic value
- Tidak ada repeating groups
- ✅ Tabel `tabel_krs_1nf` sudah memenuhi 1NF

**Third Normal Form (3NF):**
- Memenuhi 2NF (no partial dependency)
- No transitive dependency (non-key attributes tidak bergantung pada non-key lain)
- ✅ Tabel `mahasiswa`, `dosen`, `mata_kuliah`, `krs` sudah memenuhi 3NF

**Denormalization:**
- Sengaja melanggar normalisasi untuk performance
- Trade-off: Speed vs Integrity
- Butuh dokumentasi & maintenance yang ketat

---

**Good luck dengan tugas Basis Data Lanjut! 🎓**
