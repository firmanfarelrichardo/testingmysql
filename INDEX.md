# 📑 INDEX - DAFTAR ISI PROJECT

## 🗂️ STRUKTUR FILE & NAVIGASI

Berikut adalah panduan lengkap untuk navigasi project experiment Database 1NF vs 3NF:

---

## 📄 FILE UTAMA

### **1. 📖 README.md** ← MULAI DI SINI!
**Deskripsi:** Panduan lengkap step-by-step dari awal sampai akhir  
**Kapan Dibaca:** Pertama kali sebelum mulai project  
**Isi:**
- Overview project
- Quick start guide (setup environment → generate data → testing)
- Troubleshooting
- Checklist pengerjaan

**👉 [Buka README.md](README.md)**

---

### **2. 🐍 generate_data.py**
**Deskripsi:** Script Python untuk generate 10,000+ data dummy  
**Kapan Dijalankan:** Setelah install dependencies (pip install faker)  
**Output:**
- `data_1nf.csv` → untuk tabel flat
- `data_3nf.sql` → untuk tabel normalized

**Command:**
```bash
python generate_data.py
```

**Code Highlights:**
- ✅ Modular & clean code (OOP pattern)
- ✅ Docstring lengkap untuk setiap class/function
- ✅ Naming convention Bahasa Indonesia
- ✅ 1000 mahasiswa, 50 dosen, 100 mata kuliah, 10,000+ KRS

---

### **3. 🗄️ schema_1nf.sql**
**Deskripsi:** DDL untuk membuat tabel flat (denormalized)  
**Kapan Dijalankan:** Setelah buat database di MySQL  
**Isi:**
- CREATE TABLE `tabel_krs_1nf`
- Index definitions
- Dokumentasi cara import CSV

**Command:**
```sql
USE experiment_db;
SOURCE schema_1nf.sql;
```

---

### **4. 🗄️ schema_3nf.sql**
**Deskripsi:** DDL untuk membuat 4 tabel normalized (3NF)  
**Kapan Dijalankan:** Setelah buat database di MySQL  
**Isi:**
- CREATE TABLE `mahasiswa`, `dosen`, `mata_kuliah`, `krs`
- Primary Key & Foreign Key constraints
- Index definitions
- ERD visualization (ASCII art)

**Command:**
```sql
USE experiment_db;
SOURCE schema_3nf.sql;
```

---

### **5. ⚡ benchmark_queries.sql**
**Deskripsi:** Query untuk testing performa 1NF vs 3NF  
**Kapan Dijalankan:** Setelah data sudah diload ke database  
**Isi:**
- Kasus A: Simple SELECT (cari KRS mahasiswa)
- Kasus B: Complex Aggregation (hitung SKS per dosen)
- Kasus C: UPDATE (ganti nomor HP dosen)
- Query untuk cek ukuran storage
- Template dokumentasi hasil

**Tips:** Jalankan setiap query 3-5 kali, ambil rata-rata duration

**👉 [Buka benchmark_queries.sql](benchmark_queries.sql)**

---

## 📚 FILE DOKUMENTASI

### **6. 📊 ANALISIS_DAN_PANDUAN.md**
**Deskripsi:** Analisis profesional & hipotesis performa  
**Kapan Dibaca:** Sebelum/sesudah testing untuk memahami "why"  
**Isi:**
- Hipotesis kapan 1NF menang vs 3NF menang
- Use case real-world (data warehouse vs transactional)
- Kesimpulan & rekomendasi
- Tips untuk presentasi/laporan

**Key Takeaways:**
- 1NF menang untuk simple read (3-4x lebih cepat)
- 3NF menang untuk update (100x+ lebih cepat)
- 3NF lebih hemat storage (60-70%)
- 3NF lebih aman (data integrity)

**👉 [Buka ANALISIS_DAN_PANDUAN.md](ANALISIS_DAN_PANDUAN.md)**

---

### **7. 📖 KONSEP_TEORI.md**
**Deskripsi:** Penjelasan teori normalisasi (Formal + ELI5)  
**Kapan Dibaca:** Untuk belajar konsep/persiapan ujian  
**Isi:**
- Penjelasan 1NF, 2NF, 3NF (dengan contoh)
- Glossary: Redundancy, Anomaly, Cardinality, Indexing
- Perbandingan 1NF vs 3NF
- Real-world examples

**Target Audience:**
- Mahasiswa yang belajar normalisasi
- Persiapan ujian/presentasi
- Reference untuk memahami "why we normalize"

**👉 [Buka KONSEP_TEORI.md](KONSEP_TEORI.md)**

---

### **8. 🚀 CHEAT_SHEET.md**
**Deskripsi:** Command cepat untuk copy-paste  
**Kapan Dibaca:** Saat eksekusi (quick reference)  
**Isi:**
- Setup environment (pip install)
- Generate data (python command)
- Setup database (SQL commands)
- Load data (import CSV & SQL dump)
- Benchmark queries (ready to copy-paste)
- Troubleshooting common errors

**Tips:** Simpan file ini di tab terpisah saat testing!

**👉 [Buka CHEAT_SHEET.md](CHEAT_SHEET.md)**

---

## 🔧 FILE KONFIGURASI

### **9. 📦 requirements.txt**
**Deskripsi:** Dependencies Python  
**Kapan Digunakan:** Sebelum run script Python  
**Isi:**
- faker==21.0.0

**Command:**
```bash
pip install -r requirements.txt
```

---

## 📊 FILE OUTPUT (Akan Digenerate)

### **10. 📄 data_1nf.csv** (Generated)
**Deskripsi:** Data dummy dalam format CSV flat  
**Kapan Dibuat:** Setelah run `python generate_data.py`  
**Format:**
```
nim,nama_mhs,kode_mk,nama_mk,sks,nidn_dosen,nama_dosen,nohp_dosen
20200001,Budi,IF001,Basis Data,3,0123456789,Dr. Siti,081234567890
...
```

**Ukuran:** ~2-3 MB  
**Rows:** 10,000+

---

### **11. 📄 data_3nf.sql** (Generated)
**Deskripsi:** SQL dump untuk tabel normalized  
**Kapan Dibuat:** Setelah run `python generate_data.py`  
**Format:**
```sql
INSERT INTO mahasiswa (nim, nama_lengkap) VALUES ('20200001', 'Budi');
INSERT INTO dosen (nidn, nama_lengkap, no_hp) VALUES ('0123456789', 'Dr. Siti', '081234567890');
...
```

**Ukuran:** ~3-4 MB  
**Statements:** 11,150+ INSERT commands

---

## 🗺️ RECOMMENDED READING ORDER

### **Untuk Pemula (First Time):**
1. ✅ **README.md** → Understand project overview
2. ✅ **KONSEP_TEORI.md** → Learn normalization basics
3. ✅ **CHEAT_SHEET.md** → Execute step-by-step
4. ✅ **benchmark_queries.sql** → Run tests
5. ✅ **ANALISIS_DAN_PANDUAN.md** → Analyze results

### **Untuk Quick Execution:**
1. ✅ **CHEAT_SHEET.md** → Copy-paste commands
2. ✅ **benchmark_queries.sql** → Run tests
3. ✅ **ANALISIS_DAN_PANDUAN.md** → Interpret results

### **Untuk Persiapan Presentasi:**
1. ✅ **KONSEP_TEORI.md** → Theory background
2. ✅ **ANALISIS_DAN_PANDUAN.md** → Analysis & conclusion
3. ✅ **benchmark_queries.sql** → Show demo queries

---

## 🎯 WORKFLOW LENGKAP (30 Menit)

```
[ 5 min] Setup Environment
         └─ pip install -r requirements.txt

[ 2 min] Generate Data
         └─ python generate_data.py

[ 5 min] Setup Database
         ├─ CREATE DATABASE experiment_db
         ├─ SOURCE schema_1nf.sql
         └─ SOURCE schema_3nf.sql

[ 8 min] Load Data
         ├─ Import data_1nf.csv (via Workbench)
         └─ SOURCE data_3nf.sql

[10 min] Run Benchmark
         ├─ KASUS A: Simple SELECT (1NF vs 3NF)
         ├─ KASUS B: Complex Aggregation (1NF vs 3NF)
         └─ KASUS C: UPDATE (1NF vs 3NF)

[ 5 min] Dokumentasi Hasil
         └─ Screenshot + Tabel perbandingan

TOTAL: ~30 menit untuk full experiment
```

---

## 📞 QUICK HELP

### **Error saat generate data?**
→ Cek **CHEAT_SHEET.md** bagian Troubleshooting

### **Bingung konsep normalisasi?**
→ Baca **KONSEP_TEORI.md** dari awal

### **Mau langsung eksekusi?**
→ Follow **README.md** step-by-step

### **Butuh template laporan?**
→ Lihat **ANALISIS_DAN_PANDUAN.md** bagian "Tips untuk Presentasi"

---

## 🏆 SUCCESS CRITERIA

Checklist untuk memastikan experiment berhasil:

- [ ] ✅ File `data_1nf.csv` dan `data_3nf.sql` sudah digenerate
- [ ] ✅ Database `experiment_db` sudah dibuat
- [ ] ✅ 5 tabel sudah ada (tabel_krs_1nf + 4 tabel 3NF)
- [ ] ✅ Data sudah diload (10,000+ rows)
- [ ] ✅ Benchmark queries berjalan tanpa error
- [ ] ✅ Duration tercatat untuk setiap query
- [ ] ✅ Hasil didokumentasikan dalam tabel perbandingan
- [ ] ✅ Screenshot untuk laporan
- [ ] ✅ Analisis & kesimpulan ditulis

---

**Happy Learning! 🎓🚀**

**Questions? Check:**
- 📖 README.md
- 🚀 CHEAT_SHEET.md
- 📚 KONSEP_TEORI.md
