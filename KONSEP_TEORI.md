# 📚 KONSEP TEORI: NORMALISASI DATABASE

## 🎯 APA ITU NORMALISASI?

### **Definisi Formal (Textbook):**
Normalisasi adalah proses mengorganisir data dalam database untuk:
1. Mengurangi redundansi (duplikasi data)
2. Menghindari anomali (insert, update, delete anomaly)
3. Meningkatkan integritas data

### **Definisi Sederhana (ELI5 - Explain Like I'm 5):**
Normalisasi itu kayak **organize lemari baju**:
- **Sebelum (1NF/Denormalized):** Semua baju dicampur jadi satu → cepat ambil, tapi ribet kalau mau ganti label
- **Sesudah (3NF/Normalized):** Baju dipilah per kategori (kaos, celana, jacket) → lebih rapi, ganti label gampang

---

## 📊 TINGKATAN NORMALISASI

### **1NF (First Normal Form)**

#### **Syarat:**
- Setiap kolom hanya berisi **atomic value** (nilai tunggal)
- Tidak ada **repeating groups** (grup data berulang)

#### **Contoh SALAH (Bukan 1NF):**
```
mahasiswa_table:
+-----+-------+------------------------------+
| nim | nama  | mata_kuliah                  |
+-----+-------+------------------------------+
| 123 | Budi  | Basis Data, Algoritma, Web   | ← NOT ATOMIC!
+-----+-------+------------------------------+
```

#### **Contoh BENAR (Sudah 1NF):**
```
mahasiswa_mk_table:
+-----+-------+-------------+
| nim | nama  | mata_kuliah |
+-----+-------+-------------+
| 123 | Budi  | Basis Data  |
| 123 | Budi  | Algoritma   |
| 123 | Budi  | Web         |
+-----+-------+-------------+
```

✅ Setiap cell hanya 1 nilai  
⚠️ Tapi masih ada duplikasi nama "Budi"

---

### **2NF (Second Normal Form)**

#### **Syarat:**
- Sudah memenuhi **1NF**
- Tidak ada **partial dependency** (atribut non-key bergantung pada sebagian primary key)

#### **Contoh SALAH (Bukan 2NF):**
```
krs_table (Primary Key: nim + kode_mk):
+-----+----------+-------+-------------+
| nim | kode_mk  | nama  | nama_mk     |
+-----+----------+-------+-------------+
| 123 | BD101    | Budi  | Basis Data  |
| 123 | ALG101   | Budi  | Algoritma   | ← "Budi" cuma depend on nim, bukan (nim+kode_mk)
+-----+----------+-------+-------------+
```

**Problem:** Kolom `nama` hanya bergantung pada `nim`, bukan pada kombinasi `nim + kode_mk`.

#### **Contoh BENAR (Sudah 2NF):**

Pecah jadi 2 tabel:

**Tabel 1: mahasiswa**
```
+-----+-------+
| nim | nama  |
+-----+-------+
| 123 | Budi  |
+-----+-------+
```

**Tabel 2: krs**
```
+-----+----------+
| nim | kode_mk  |
+-----+----------+
| 123 | BD101    |
| 123 | ALG101   |
+-----+----------+
```

✅ Tidak ada partial dependency  
⚠️ Tapi masih bisa ada transitive dependency

---

### **3NF (Third Normal Form)** ← YANG KITA PAKAI!

#### **Syarat:**
- Sudah memenuhi **2NF**
- Tidak ada **transitive dependency** (atribut non-key tidak bergantung pada atribut non-key lain)

#### **Contoh SALAH (Bukan 3NF):**
```
mata_kuliah_table:
+----------+-------------+------+-------------+---------------+
| kode_mk  | nama_mk     | sks  | nidn_dosen  | nama_dosen    |
+----------+-------------+------+-------------+---------------+
| BD101    | Basis Data  | 3    | 001         | Dr. Siti      |
| ALG101   | Algoritma   | 4    | 001         | Dr. Siti      | ← nama_dosen depend on nidn_dosen
+----------+-------------+------+-------------+---------------+
```

**Problem:** `nama_dosen` bergantung pada `nidn_dosen` (bukan pada primary key `kode_mk`).

#### **Contoh BENAR (Sudah 3NF):**

Pecah jadi 2 tabel:

**Tabel 1: mata_kuliah**
```
+----------+-------------+------+-------------+
| kode_mk  | nama_mk     | sks  | nidn_dosen  |
+----------+-------------+------+-------------+
| BD101    | Basis Data  | 3    | 001         |
| ALG101   | Algoritma   | 4    | 001         |
+----------+-------------+------+-------------+
```

**Tabel 2: dosen**
```
+-------------+-------------+
| nidn        | nama_dosen  |
+-------------+-------------+
| 001         | Dr. Siti    |
+-------------+-------------+
```

✅ Tidak ada transitive dependency  
✅ Data dosen hanya disimpan 1x  
✅ Update nama dosen cukup di 1 tempat

---

## 💡 GLOSSARY ISTILAH PENTING

### **1. Redundancy (Redundansi)**

**Formal:** Duplikasi data yang tidak perlu dalam database.

**Simple:** Data yang sama disimpan berkali-kali.

**Contoh:**
```
1NF Table (10,000 rows):
- Nama "Budi" muncul 10x (untuk 10 mata kuliah yang dia ambil)
- Nama dosen "Dr. Siti" muncul 500x (untuk 500 mahasiswa yang ambil kelasnya)

3NF Table:
- Nama "Budi" disimpan 1x di tabel mahasiswa
- Nama "Dr. Siti" disimpan 1x di tabel dosen
```

**Akibat Redundancy:**
- ❌ Ukuran database membengkak
- ❌ Lebih lambat untuk update/delete
- ❌ Risiko inkonsistensi data

---

### **2. Anomaly (Anomali)**

Masalah yang muncul karena struktur database yang buruk.

#### **A. Insert Anomaly**

**Formal:** Tidak bisa insert data karena data lain belum ada.

**Simple:** Tidak bisa simpan info dosen baru kalau belum ada mahasiswa yang ambil kelasnya.

**Contoh di 1NF:**
```
Mau insert dosen baru "Dr. Budi"
Tapi di 1NF, dosen hanya muncul kalau ada mahasiswa yang ambil KRS
Solution: Terpaksa buat dummy mahasiswa (jelek!)
```

**Di 3NF:** Bisa langsung `INSERT INTO dosen` tanpa perlu relasi dulu.

#### **B. Update Anomaly**

**Formal:** Update data di satu tempat, tapi lupa update di tempat lain → inkonsistensi.

**Simple:** Dosen ganti nomor HP, harus update ribuan baris.

**Contoh di 1NF:**
```sql
-- Dosen "Dr. Siti" ganti HP
-- Harus update 500 rows!
UPDATE tabel_krs_1nf SET nohp_dosen = 'XXX' WHERE nidn_dosen = '001';

-- Kalau error di row ke-250, data jadi inkonsisten:
-- Row 1-249: HP lama
-- Row 250-500: HP baru  ← DISASTER!
```

**Di 3NF:**
```sql
-- Cukup update 1 row
UPDATE dosen SET no_hp = 'XXX' WHERE nidn = '001';
```

#### **C. Delete Anomaly**

**Formal:** Menghapus data, tapi kehilangan info penting lain.

**Simple:** Hapus mahasiswa terakhir, data dosennya ikut hilang.

**Contoh di 1NF:**
```
Mahasiswa "Budi" adalah satu-satunya yang ambil kelas Dr. Joko
DELETE FROM tabel_krs_1nf WHERE nim = '123';
→ Data Dr. Joko hilang dari database! (padahal dosennya masih ada)
```

**Di 3NF:** Data dosen tetap ada di tabel `dosen` meskipun tidak ada mahasiswa.

---

### **3. Cardinality (Kardinalitas)**

**Formal:** Jumlah hubungan antar entitas dalam relasi database.

**Simple:** Berapa banyak A bisa berhubungan dengan B?

#### **Jenis-Jenis:**

**1:1 (One-to-One)**
```
Mahasiswa ↔ Kartu Mahasiswa
Satu mahasiswa punya 1 kartu, 1 kartu untuk 1 mahasiswa
```

**1:N (One-to-Many)**
```
Dosen ↔ Mata Kuliah
Satu dosen bisa mengajar banyak MK
Satu MK hanya diampu 1 dosen
```

**N:M (Many-to-Many)**
```
Mahasiswa ↔ Mata Kuliah
Satu mahasiswa bisa ambil banyak MK
Satu MK bisa diambil banyak mahasiswa
→ Butuh tabel junction (KRS)
```

---

### **4. Indexing (Pengindeksan)**

**Formal:** Struktur data tambahan untuk mempercepat pencarian.

**Simple:** Kayak **daftar isi buku** → langsung loncat ke halaman yang dicari.

**Contoh:**
```sql
-- Tanpa Index:
SELECT * FROM mahasiswa WHERE nama = 'Budi';
→ MySQL harus scan 1000 rows (LAMBAT)

-- Dengan Index:
CREATE INDEX idx_nama ON mahasiswa(nama);
SELECT * FROM mahasiswa WHERE nama = 'Budi';
→ MySQL langsung jump ke 'Budi' (CEPAT)
```

**Trade-off:**
- ✅ SELECT lebih cepat
- ❌ INSERT/UPDATE sedikit lebih lambat (harus update index)
- ❌ Ukuran database bertambah

**Best Practice:**
- Index pada kolom yang sering di-WHERE/JOIN
- Jangan index semua kolom (overkill)

---

## 🔍 PERBANDINGAN: 1NF vs 3NF

| **Aspek**              | **1NF (Denormalized)**       | **3NF (Normalized)**          |
|------------------------|------------------------------|-------------------------------|
| **Redundancy**         | ❌ Tinggi (data duplikat)    | ✅ Minimal                    |
| **Storage**            | ❌ Boros (5-10 MB)           | ✅ Hemat (2-3 MB)             |
| **Simple SELECT**      | ✅ Cepat (no JOIN)           | ⚠️ Agak lambat (JOIN)         |
| **Complex Query**      | ⚠️ Susah (butuh DISTINCT)    | ✅ Mudah (relasi jelas)       |
| **UPDATE**             | ❌ Lambat (update ribuan)    | ✅ Cepat (update 1 row)       |
| **Data Integrity**     | ❌ Risiko inkonsistensi      | ✅ Aman (FK constraint)       |
| **Maintenance**        | ❌ Sulit                     | ✅ Mudah                      |
| **Use Case**           | Reporting, Analytics         | Transactional System          |

---

## 📖 CONTOH REAL-WORLD

### **Kapan Pakai 1NF (Denormalized)?**

**1. Data Warehouse (OLAP)**
```
Scenario: Laporan penjualan tahunan
- Data sudah final (tidak pernah diupdate)
- Query: agregasi sederhana (SUM, AVG, COUNT)
- Prioritas: Speed over Storage
```

**2. Cache/Session Storage**
```
Scenario: User session data
- Temporary data (hilang setelah logout)
- Tidak perlu relasi kompleks
- Prioritas: Ultra-fast read
```

**3. Log Files**
```
Scenario: Server access logs
- Write-once, read-many
- Tidak ada update/delete
- Prioritas: Simple queries
```

---

### **Kapan Pakai 3NF (Normalized)?**

**1. Sistem Akademik** ← SEPERTI TUGAS INI!
```
Scenario: Mahasiswa, Dosen, Mata Kuliah, KRS
- Data sering berubah (add/drop MK, ganti dosen)
- Relasi kompleks (many-to-many)
- Prioritas: Data integrity & consistency
```

**2. E-Commerce (Order Management)**
```
Scenario: Customers, Products, Orders, OrderItems
- Data transactional (order status berubah)
- Butuh referential integrity (product stock update)
- Prioritas: ACID compliance
```

**3. Banking System**
```
Scenario: Accounts, Transactions, Customers
- Data sangat kritikal (uang!)
- Tidak boleh ada inkonsistensi
- Prioritas: Data integrity > Speed
```

---

## 🎓 TIPS UNTUK UJIAN/PRESENTASI

### **Pertanyaan yang Sering Muncul:**

**Q: "Kenapa tidak pakai BCNF atau 4NF?"**  
A: "Untuk kebanyakan aplikasi, 3NF sudah cukup. BCNF/4NF untuk kasus khusus dengan multi-valued dependencies."

**Q: "Denormalization selalu buruk?"**  
A: "Tidak! Di data warehouse/analytics, denormalization justru best practice."

**Q: "Bagaimana tahu kapan denormalize?"**  
A: "Lihat query pattern: 90% read + simple queries = consider denormalization. 50/50 read/write + complex = stay normalized."

**Q: "Apakah JOIN selalu lambat?"**  
A: "Tidak kalau ada index yang tepat. MySQL optimizer sangat pintar."

---

**Good luck dengan ujian Basis Data Lanjut! 📚🚀**
