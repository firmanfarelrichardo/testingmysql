"""
===================================================================================
GENERATOR DATA DUMMY UNTUK EXPERIMENT DATABASE 1NF VS 3NF
===================================================================================
Deskripsi:
    Script ini menghasilkan data dummy untuk sistem akademik (KRS) dengan
    konsistensi data yang dijaga. 
    
    UPDATE LOG:
    - Menambahkan logika gelar akademik (Depan & Belakang) untuk Dosen.
    
Output:
    1. data_1nf.csv: File CSV flat (denormalized)
    2. data_3nf.sql: SQL dump untuk tabel ternormalisasi
    
Author: Database Engineering Experiment
Date: December 2025
===================================================================================
"""

import csv
import random
from faker import Faker

# Inisialisasi Faker dengan locale Indonesia
fake = Faker('id_ID')
Faker.seed(42)  # Untuk hasil yang reproducible
random.seed(42)

# ========== KONFIGURASI ==========
JUMLAH_MAHASISWA = 1000
JUMLAH_DOSEN = 50
JUMLAH_MATA_KULIAH = 100
JUMLAH_TRANSAKSI_KRS = 10000

# ========== MASTER DATA CONTAINERS ==========
data_mahasiswa = []
data_dosen = []
data_mata_kuliah = []
data_krs = []

# ========== FUNGSI HELPER ==========

def generate_nim(index):
    """Generate NIM dengan format: 2020XXXXX (5 digit unik)"""
    return f"2020{str(index).zfill(5)}"

def generate_nidn(index):
    """Generate NIDN dengan format: 01XXXXXXXX (8 digit unik)"""
    return f"01{str(index).zfill(8)}"

def generate_kode_mk(index):
    """Generate Kode MK dengan format: SI001, SI002, dst"""
    return f"SI{str(index).zfill(3)}"

def generate_no_hp_indonesia():
    """Generate nomor HP Indonesia dengan format 08xx-xxxx-xxxx"""
    prefixes = ['0811', '0812', '0813', '0821', '0822', '0823', '0851', '0852', '0853', '0856', '0857', '0858']
    prefix = random.choice(prefixes)
    suffix = ''.join([str(random.randint(0, 9)) for _ in range(8)])
    return f"{prefix}-{suffix[:4]}-{suffix[4:]}"

def generate_nama_mahasiswa():
    """Generate nama mahasiswa (Tanpa Gelar)"""
    return f"{fake.first_name()} {fake.last_name()}"

def generate_nama_dosen_bergelar():
    """
    Generate nama dosen lengkap dengan gelar depan dan belakang
    secara random namun logis.
    """
    nama_dasar = f"{fake.first_name()} {fake.last_name()}"
    
    # Opsi Gelar Depan
    # Bobot: Kosong (40%), Ir. (10%), Dr. (30%), Prof. Dr. (20%)
    list_gelar_depan = ['', '', '', '', 'Ir.', 'Dr.', 'Dr.', 'Dr.', 'Prof. Dr.', 'Prof. Dr.']
    gelar_depan = random.choice(list_gelar_depan)
    
    # Opsi Gelar Belakang (Komputer & Teknik)
    list_gelar_belakang = [
        'S.Kom., M.Kom.', 
        'S.T., M.T.', 
        'S.Si., M.Cs.', 
        'M.Kom., Ph.D.', 
        'S.Kom., M.T.',
        'S.Kom., M.MSI',
        'S.T., M.Eng.',
        'Ph.D.'
    ]
    gelar_belakang = random.choice(list_gelar_belakang)
    
    # Merakit Nama
    if gelar_depan:
        return f"{gelar_depan} {nama_dasar}, {gelar_belakang}"
    else:
        return f"{nama_dasar}, {gelar_belakang}"

def generate_nama_mk():
    """Generate nama mata kuliah IT yang realistis"""
    mata_kuliah_list = [
        "Algoritma dan Pemrograman", "Basis Data", "Struktur Data",
        "Sistem Operasi", "Jaringan Komputer", "Pemrograman Web",
        "Kecerdasan Buatan", "Machine Learning", "Data Mining",
        "Keamanan Informasi", "Mobile Programming", "Cloud Computing",
        "PBO Lanjut", "Matematika Diskrit", "Statistika Probabilitas",
        "Aljabar Linear", "Kalkulus I", "Kalkulus II",
        "Rekayasa Perangkat Lunak", "Interaksi Manusia dan Komputer",
        "Grafika Komputer", "Pengolahan Citra Digital", "Sistem Informasi Manajemen",
        "ERP Systems", "Business Intelligence", "Internet of Things (IoT)", 
        "Blockchain Technology", "DevOps Engineering", "Software Testing", 
        "Metodologi Agile", "Analisis Desain Sistem", "Cyber Security", 
        "Network Security", "Ethical Hacking", "Digital Forensics", 
        "Audit Sistem Informasi", "Big Data Analytics", "Visualisasi Data", 
        "Natural Language Processing", "Computer Vision", "Deep Learning", 
        "Reinforcement Learning", "Web Development Lanjut", "Game Development", 
        "Augmented Reality", "Virtual Reality", "Robotika Dasar", 
        "Sistem Tertanam", "Pemrograman Mikrokontroler", "Sinyal Digital", 
        "Arsitektur Komputer", "Teknik Kompilasi", "Sistem Terdistribusi", 
        "Komputasi Paralel", "Quantum Computing Intro", "Bioinformatika", 
        "E-Commerce Strategy", "Digital Marketing", "Manajemen Proyek TI", 
        "Penjaminan Mutu Software", "User Experience (UX) Design",
        "Information Retrieval", "Semantic Web", "Manajemen Pengetahuan", 
        "Sistem Pendukung Keputusan", "Sistem Pakar", "Logika Fuzzy", 
        "Jaringan Syaraf Tiruan", "Algoritma Genetika", "Smart City", 
        "Pengembangan Aplikasi Mobile", "Pemrograman Lintas Platform", 
        "Desain API", "Arsitektur Microservices", "Komputasi Serverless", 
        "Manajemen Basis Data Lanjut", "Data Warehouse"
    ]
    return random.choice(mata_kuliah_list)

# ========== STEP 1: GENERATE MAHASISWA ==========
print("🔄 Generating Mahasiswa...")
for i in range(1, JUMLAH_MAHASISWA + 1):
    data_mahasiswa.append({
        'nim': generate_nim(i),
        'nama_lengkap': generate_nama_mahasiswa(), # Mahasiswa nama biasa
        'nohp_mhs': generate_no_hp_indonesia()
    })
print(f"✅ {JUMLAH_MAHASISWA} Mahasiswa berhasil digenerate")

# ========== STEP 2: GENERATE DOSEN (DENGAN GELAR) ==========
print("🔄 Generating Dosen (dengan gelar akademik)...")
for i in range(1, JUMLAH_DOSEN + 1):
    data_dosen.append({
        'nidn': generate_nidn(i),
        'nama_lengkap': generate_nama_dosen_bergelar() # Dosen pakai gelar
    })
print(f"✅ {JUMLAH_DOSEN} Dosen berhasil digenerate")

# ========== STEP 3: GENERATE MATA KULIAH ==========
print("🔄 Generating Mata Kuliah...")
sks_options = [2, 3, 4]
nama_mk_used = set()

for i in range(1, JUMLAH_MATA_KULIAH + 1):
    # Generate nama MK unik
    nama_mk = generate_nama_mk()
    attempt = 0
    while nama_mk in nama_mk_used and attempt < 100:
        nama_mk = generate_nama_mk()
        attempt += 1
    nama_mk_used.add(nama_mk)
    
    data_mata_kuliah.append({
        'kode_mk': generate_kode_mk(i),
        'nama_mk': nama_mk,
        'sks': random.choice(sks_options),
        'nidn_dosen': random.choice(data_dosen)['nidn']
    })
print(f"✅ {JUMLAH_MATA_KULIAH} Mata Kuliah berhasil digenerate")

# ========== STEP 4: GENERATE KRS (TRANSAKSI) ==========
print("🔄 Generating Transaksi KRS...")

kombinasi_unik = set()
attempt_count = 0
max_attempts = JUMLAH_TRANSAKSI_KRS * 5

while len(data_krs) < JUMLAH_TRANSAKSI_KRS and attempt_count < max_attempts:
    mhs = random.choice(data_mahasiswa)
    mk = random.choice(data_mata_kuliah)
    
    kombinasi = (mhs['nim'], mk['kode_mk'])
    
    if kombinasi not in kombinasi_unik:
        kombinasi_unik.add(kombinasi)
        
        # Ambil data dosen (yang sudah ada gelarnya)
        dosen = next(d for d in data_dosen if d['nidn'] == mk['nidn_dosen'])
        
        data_krs.append({
            'nim': mhs['nim'],
            'nama_mhs': mhs['nama_lengkap'],
            'kode_mk': mk['kode_mk'],
            'nama_mk': mk['nama_mk'],
            'sks': mk['sks'],
            'nidn_dosen': dosen['nidn'],
            'nama_dosen': dosen['nama_lengkap'], # Ini akan berisi nama bergelar
            'nohp_mhs': mhs['nohp_mhs']
        })
    
    attempt_count += 1

print(f"✅ {len(data_krs)} Transaksi KRS berhasil digenerate")

# ========== STEP 5: EXPORT KE CSV (1NF) ==========
print("🔄 Exporting ke CSV (1NF)...")

with open('data_1nf.csv', 'w', newline='', encoding='utf-8') as csvfile:
    fieldnames = ['nim', 'nama_mhs', 'kode_mk', 'nama_mk', 'sks', 'nidn_dosen', 'nama_dosen', 'nohp_mhs']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(data_krs)

print(f"✅ File 'data_1nf.csv' berhasil dibuat")

# ========== STEP 6: EXPORT KE SQL (3NF) ==========
print("🔄 Exporting ke SQL (3NF)...")

with open('data_3nf.sql', 'w', encoding='utf-8') as sqlfile:
    # 1. Insert Mahasiswa
    sqlfile.write("-- ========== INSERT MAHASISWA ==========\n")
    for mhs in data_mahasiswa:
        nama_escaped = mhs['nama_lengkap'].replace("'", "''")
        nohp_escaped = mhs['nohp_mhs'].replace("'", "''")
        sqlfile.write(f"INSERT INTO mahasiswa (nim, nama_lengkap, nohp_mhs) VALUES ('{mhs['nim']}', '{nama_escaped}', '{nohp_escaped}');\n")
    
    sqlfile.write("\n")
    
    # 2. Insert Dosen (Sekarang dengan Gelar)
    sqlfile.write("-- ========== INSERT DOSEN ==========\n")
    for dsn in data_dosen:
        # Replace single quote untuk safety SQL (misal O'Neil), meski jarang di nama Indo
        nama_escaped = dsn['nama_lengkap'].replace("'", "''")
        sqlfile.write(f"INSERT INTO dosen (nidn, nama_lengkap) VALUES ('{dsn['nidn']}', '{nama_escaped}');\n")
    
    sqlfile.write("\n")
    
    # 3. Insert Mata Kuliah
    sqlfile.write("-- ========== INSERT MATA KULIAH ==========\n")
    for mk in data_mata_kuliah:
        nama_mk_escaped = mk['nama_mk'].replace("'", "''")
        sqlfile.write(f"INSERT INTO mata_kuliah (kode_mk, nama_mk, sks, nidn_dosen) VALUES ('{mk['kode_mk']}', '{nama_mk_escaped}', {mk['sks']}, '{mk['nidn_dosen']}');\n")
    
    sqlfile.write("\n")
    
    # 4. Insert KRS
    sqlfile.write("-- ========== INSERT KRS ==========\n")
    
    # Kita bagi INSERT KRS menjadi batch/chunks agar file SQL lebih mudah di-handle editor text
    # (Opsional: tapi bagus untuk performance import)
    sqlfile.write("INSERT INTO krs (nim, kode_mk) VALUES \n")
    
    values_list = []
    for i, krs in enumerate(data_krs):
        values_list.append(f"('{krs['nim']}', '{krs['kode_mk']}')")
        
        # Setiap 1000 row, kita tutup statement dan buat INSERT baru (agar buffer tidak overload)
        if (i + 1) % 1000 == 0 and (i + 1) < len(data_krs):
            sqlfile.write(",\n".join(values_list) + ";\n")
            sqlfile.write("INSERT INTO krs (nim, kode_mk) VALUES \n")
            values_list = []
            
    # Tulis sisa data
    if values_list:
        sqlfile.write(",\n".join(values_list) + ";\n")

print(f"✅ File 'data_3nf.sql' berhasil dibuat")

# ========== SUMMARY ==========
print("\n" + "="*60)
print("📊 SUMMARY GENERATION (UPDATED WITH TITLES)")
print("="*60)
print(f"✅ Total Mahasiswa      : {len(data_mahasiswa):,}")
print(f"✅ Total Dosen          : {len(data_dosen):,}")
print(f"✅ Total Mata Kuliah    : {len(data_mata_kuliah):,}")
print(f"✅ Total Transaksi KRS  : {len(data_krs):,}")
print(f"\n📁 File Output Siap:")
print(f"   - data_1nf.csv (Cek kolom nama_dosen, sudah ada gelar)")
print(f"   - data_3nf.sql (Siap import ke Database)")
print("="*60)