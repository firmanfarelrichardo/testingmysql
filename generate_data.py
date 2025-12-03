"""
===================================================================================
GENERATOR DATA DUMMY UNTUK EXPERIMENT DATABASE 1NF VS 3NF
===================================================================================
Deskripsi:
    Script ini menghasilkan data dummy untuk sistem akademik (KRS) dengan
    konsistensi data yang dijaga. Output berupa:
    1. data_1nf.csv: File CSV flat (denormalized)
    2. data_3nf.sql: SQL dump untuk tabel ternormalisasi
    
Spesifikasi Data:
    - 1.000 Mahasiswa unik
    - 50 Dosen unik
    - 100 Mata Kuliah unik (tiap MK diampu 1 dosen)
    - 10.000+ Transaksi KRS (mahasiswa mengambil mata kuliah)
    
Author: Database Engineering Experiment
Date: December 2025
===================================================================================
"""

import csv
import random
from faker import Faker
from datetime import datetime

# Inisialisasi Faker dengan locale Indonesia
fake = Faker('id_ID')
Faker.seed(12345)  # Untuk reproducibility
random.seed(12345)


class MahasiswaGenerator:
    """
    Generator untuk membuat data dummy mahasiswa.
    Menghasilkan NIM unik dan nama lengkap yang realistis.
    """
    
    def __init__(self, jumlah=1000):
        """
        Args:
            jumlah (int): Jumlah mahasiswa yang akan digenerate
        """
        self.jumlah = jumlah
        self.data_mahasiswa = []
    
    def generate(self):
        """
        Generate data mahasiswa dengan NIM format: YYYYNNNNN
        YYYY = Tahun masuk (2020-2024)
        NNNNN = Nomor urut 5 digit
        
        Returns:
            list: List of dict berisi nim dan nama_lengkap
        """
        print(f"[INFO] Generating {self.jumlah} data mahasiswa...")
        
        for i in range(self.jumlah):
            tahun_masuk = random.choice([2020, 2021, 2022, 2023, 2024])
            nomor_urut = str(i + 1).zfill(5)
            nim = f"{tahun_masuk}{nomor_urut}"
            nama_lengkap = fake.name()
            
            self.data_mahasiswa.append({
                'nim': nim,
                'nama_lengkap': nama_lengkap
            })
        
        print(f"[SUCCESS] {len(self.data_mahasiswa)} mahasiswa berhasil digenerate")
        return self.data_mahasiswa


class DosenGenerator:
    """
    Generator untuk membuat data dummy dosen.
    Menghasilkan NIDN unik, nama, dan nomor HP.
    """
    
    def __init__(self, jumlah=50):
        """
        Args:
            jumlah (int): Jumlah dosen yang akan digenerate
        """
        self.jumlah = jumlah
        self.data_dosen = []
    
    def generate(self):
        """
        Generate data dosen dengan NIDN format: 10 digit angka
        
        Returns:
            list: List of dict berisi nidn, nama_lengkap, no_hp
        """
        print(f"[INFO] Generating {self.jumlah} data dosen...")
        
        for i in range(self.jumlah):
            nidn = f"0{str(random.randint(100000000, 999999999))}"
            nama_lengkap = fake.name()
            no_hp = fake.phone_number()
            
            self.data_dosen.append({
                'nidn': nidn,
                'nama_lengkap': nama_lengkap,
                'no_hp': no_hp
            })
        
        print(f"[SUCCESS] {len(self.data_dosen)} dosen berhasil digenerate")
        return self.data_dosen


class MataKuliahGenerator:
    """
    Generator untuk membuat data dummy mata kuliah.
    Setiap MK akan diassign ke satu dosen pengampu.
    """
    
    def __init__(self, jumlah=100, data_dosen=None):
        """
        Args:
            jumlah (int): Jumlah mata kuliah yang akan digenerate
            data_dosen (list): List data dosen untuk assignment
        """
        self.jumlah = jumlah
        self.data_dosen = data_dosen or []
        self.data_mata_kuliah = []
        
        # Daftar nama mata kuliah yang umum
        self.nama_mk_pool = [
            "Basis Data", "Algoritma", "Struktur Data", "Pemrograman Web",
            "Sistem Operasi", "Jaringan Komputer", "Kecerdasan Buatan",
            "Machine Learning", "Data Mining", "Sistem Informasi",
            "Rekayasa Perangkat Lunak", "Grafika Komputer", "Komputer Vision",
            "Keamanan Siber", "Cloud Computing", "Mobile Programming",
            "Internet of Things", "Blockchain", "DevOps", "UI/UX Design",
            "Matematika Diskrit", "Statistika", "Kalkulus", "Aljabar Linear",
            "Fisika Dasar", "Bahasa Inggris", "Pancasila", "Kewarganegaraan",
            "Etika Profesi", "Kewirausahaan", "Manajemen Proyek",
            "Analisis dan Perancangan Sistem", "Pemrograman Berorientasi Objek",
            "Pemrograman Fungsional", "Teori Komputasi", "Automata"
        ]
    
    def generate(self):
        """
        Generate data mata kuliah dengan kode MK format: XXnnn
        XX = Prefix (IF, SI, TI, dll)
        nnn = Nomor urut 3 digit
        
        Returns:
            list: List of dict berisi kode_mk, nama_mk, sks, nidn_dosen
        """
        print(f"[INFO] Generating {self.jumlah} data mata kuliah...")
        
        prefix_pool = ['IF', 'SI', 'TI', 'MI', 'KI']
        
        for i in range(self.jumlah):
            prefix = random.choice(prefix_pool)
            nomor_urut = str(i + 1).zfill(3)
            kode_mk = f"{prefix}{nomor_urut}"
            
            # Pilih nama mata kuliah dan tambahkan level
            nama_base = random.choice(self.nama_mk_pool)
            level = random.choice(['', ' I', ' II', ' III', ' Lanjut', ' Dasar'])
            nama_mk = f"{nama_base}{level}"
            
            sks = random.choice([2, 3, 4])
            
            # Assign dosen pengampu secara random
            dosen_pengampu = random.choice(self.data_dosen)
            nidn_dosen = dosen_pengampu['nidn']
            
            self.data_mata_kuliah.append({
                'kode_mk': kode_mk,
                'nama_mk': nama_mk,
                'sks': sks,
                'nidn_dosen': nidn_dosen
            })
        
        print(f"[SUCCESS] {len(self.data_mata_kuliah)} mata kuliah berhasil digenerate")
        return self.data_mata_kuliah


class KRSGenerator:
    """
    Generator untuk membuat data transaksi KRS (Kartu Rencana Studi).
    Menghubungkan mahasiswa dengan mata kuliah yang diambil.
    """
    
    def __init__(self, jumlah=10000, data_mahasiswa=None, data_mata_kuliah=None):
        """
        Args:
            jumlah (int): Jumlah transaksi KRS yang akan digenerate
            data_mahasiswa (list): List data mahasiswa
            data_mata_kuliah (list): List data mata kuliah
        """
        self.jumlah = jumlah
        self.data_mahasiswa = data_mahasiswa or []
        self.data_mata_kuliah = data_mata_kuliah or []
        self.data_krs = []
    
    def generate(self):
        """
        Generate data KRS dengan random assignment mahasiswa ke mata kuliah.
        Setiap mahasiswa bisa mengambil 3-8 mata kuliah per semester.
        
        Returns:
            list: List of dict berisi nim, kode_mk
        """
        print(f"[INFO] Generating {self.jumlah} data transaksi KRS...")
        
        transaksi_count = 0
        
        while transaksi_count < self.jumlah:
            # Pilih mahasiswa random
            mahasiswa = random.choice(self.data_mahasiswa)
            nim = mahasiswa['nim']
            
            # Setiap mahasiswa mengambil 3-8 MK (realistis per semester)
            jumlah_mk = random.randint(3, 8)
            mata_kuliah_dipilih = random.sample(self.data_mata_kuliah, 
                                                min(jumlah_mk, len(self.data_mata_kuliah)))
            
            for mk in mata_kuliah_dipilih:
                self.data_krs.append({
                    'nim': nim,
                    'kode_mk': mk['kode_mk']
                })
                transaksi_count += 1
                
                if transaksi_count >= self.jumlah:
                    break
        
        print(f"[SUCCESS] {len(self.data_krs)} transaksi KRS berhasil digenerate")
        return self.data_krs


class DataExporter:
    """
    Class untuk export data ke format CSV (1NF) dan SQL Dump (3NF).
    """
    
    def __init__(self, data_mahasiswa, data_dosen, data_mata_kuliah, data_krs):
        """
        Args:
            data_mahasiswa (list): Data mahasiswa
            data_dosen (list): Data dosen
            data_mata_kuliah (list): Data mata kuliah
            data_krs (list): Data transaksi KRS
        """
        self.data_mahasiswa = {m['nim']: m for m in data_mahasiswa}
        self.data_dosen = {d['nidn']: d for d in data_dosen}
        self.data_mata_kuliah = {mk['kode_mk']: mk for mk in data_mata_kuliah}
        self.data_krs = data_krs
    
    def export_to_1nf_csv(self, filename='data_1nf.csv'):
        """
        Export data ke format CSV (Flat Table - Denormalized).
        Semua informasi digabung dalam satu baris (banyak duplikasi).
        
        Args:
            filename (str): Nama file output CSV
        """
        print(f"\n[INFO] Exporting data ke {filename} (Format 1NF - Denormalized)...")
        
        with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
            fieldnames = [
                'nim', 'nama_mhs', 'kode_mk', 'nama_mk', 'sks', 
                'nidn_dosen', 'nama_dosen', 'nohp_dosen'
            ]
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()
            
            for krs in self.data_krs:
                nim = krs['nim']
                kode_mk = krs['kode_mk']
                
                # Lookup data dari master
                mahasiswa = self.data_mahasiswa[nim]
                mata_kuliah = self.data_mata_kuliah[kode_mk]
                dosen = self.data_dosen[mata_kuliah['nidn_dosen']]
                
                # Write row dengan semua kolom (DUPLIKASI TINGGI!)
                writer.writerow({
                    'nim': nim,
                    'nama_mhs': mahasiswa['nama_lengkap'],
                    'kode_mk': kode_mk,
                    'nama_mk': mata_kuliah['nama_mk'],
                    'sks': mata_kuliah['sks'],
                    'nidn_dosen': dosen['nidn'],
                    'nama_dosen': dosen['nama_lengkap'],
                    'nohp_dosen': dosen['no_hp']
                })
        
        print(f"[SUCCESS] File {filename} berhasil dibuat!")
    
    def export_to_3nf_sql(self, filename='data_3nf.sql'):
        """
        Export data ke format SQL Dump (Normalized - 3NF).
        Data dipecah ke tabel: mahasiswa, dosen, mata_kuliah, krs.
        
        Args:
            filename (str): Nama file output SQL
        """
        print(f"\n[INFO] Exporting data ke {filename} (Format 3NF - Normalized)...")
        
        with open(filename, 'w', encoding='utf-8') as sqlfile:
            # Header SQL
            sqlfile.write("-- ============================================\n")
            sqlfile.write("-- SQL DUMP: DATABASE 3NF (NORMALIZED)\n")
            sqlfile.write("-- Generated: " + datetime.now().strftime("%Y-%m-%d %H:%M:%S") + "\n")
            sqlfile.write("-- ============================================\n\n")
            
            # SECTION 1: INSERT DATA MAHASISWA
            sqlfile.write("-- ============================================\n")
            sqlfile.write("-- TABLE: mahasiswa\n")
            sqlfile.write("-- ============================================\n")
            
            for nim, mahasiswa in self.data_mahasiswa.items():
                nama_escaped = mahasiswa['nama_lengkap'].replace("'", "''")
                sql = f"INSERT INTO mahasiswa (nim, nama_lengkap) VALUES ('{nim}', '{nama_escaped}');\n"
                sqlfile.write(sql)
            
            sqlfile.write("\n")
            
            # SECTION 2: INSERT DATA DOSEN
            sqlfile.write("-- ============================================\n")
            sqlfile.write("-- TABLE: dosen\n")
            sqlfile.write("-- ============================================\n")
            
            for nidn, dosen in self.data_dosen.items():
                nama_escaped = dosen['nama_lengkap'].replace("'", "''")
                nohp_escaped = dosen['no_hp'].replace("'", "''")
                sql = f"INSERT INTO dosen (nidn, nama_lengkap, no_hp) VALUES ('{nidn}', '{nama_escaped}', '{nohp_escaped}');\n"
                sqlfile.write(sql)
            
            sqlfile.write("\n")
            
            # SECTION 3: INSERT DATA MATA KULIAH
            sqlfile.write("-- ============================================\n")
            sqlfile.write("-- TABLE: mata_kuliah\n")
            sqlfile.write("-- ============================================\n")
            
            for kode_mk, mk in self.data_mata_kuliah.items():
                nama_escaped = mk['nama_mk'].replace("'", "''")
                sql = f"INSERT INTO mata_kuliah (kode_mk, nama_mk, sks, nidn_dosen) VALUES ('{kode_mk}', '{nama_escaped}', {mk['sks']}, '{mk['nidn_dosen']}');\n"
                sqlfile.write(sql)
            
            sqlfile.write("\n")
            
            # SECTION 4: INSERT DATA KRS
            sqlfile.write("-- ============================================\n")
            sqlfile.write("-- TABLE: krs (Transaksi)\n")
            sqlfile.write("-- ============================================\n")
            
            for krs in self.data_krs:
                sql = f"INSERT INTO krs (nim, kode_mk) VALUES ('{krs['nim']}', '{krs['kode_mk']}');\n"
                sqlfile.write(sql)
            
            sqlfile.write("\n-- ============================================\n")
            sqlfile.write("-- END OF SQL DUMP\n")
            sqlfile.write("-- ============================================\n")
        
        print(f"[SUCCESS] File {filename} berhasil dibuat!")


def main():
    """
    Fungsi utama untuk orchestrate seluruh proses generate data.
    """
    print("="*80)
    print("DATA GENERATOR: EXPERIMENT 1NF VS 3NF DATABASE")
    print("="*80)
    print()
    
    # STEP 1: Generate Master Data Mahasiswa
    mahasiswa_gen = MahasiswaGenerator(jumlah=1000)
    data_mahasiswa = mahasiswa_gen.generate()
    print()
    
    # STEP 2: Generate Master Data Dosen
    dosen_gen = DosenGenerator(jumlah=50)
    data_dosen = dosen_gen.generate()
    print()
    
    # STEP 3: Generate Master Data Mata Kuliah (dengan assignment dosen)
    mk_gen = MataKuliahGenerator(jumlah=100, data_dosen=data_dosen)
    data_mata_kuliah = mk_gen.generate()
    print()
    
    # STEP 4: Generate Transaksi KRS (10.000+ records)
    krs_gen = KRSGenerator(jumlah=10000, 
                          data_mahasiswa=data_mahasiswa, 
                          data_mata_kuliah=data_mata_kuliah)
    data_krs = krs_gen.generate()
    print()
    
    # STEP 5: Export Data
    exporter = DataExporter(data_mahasiswa, data_dosen, data_mata_kuliah, data_krs)
    exporter.export_to_1nf_csv('data_1nf.csv')
    exporter.export_to_3nf_sql('data_3nf.sql')
    
    print("\n" + "="*80)
    print("DATA GENERATION COMPLETED SUCCESSFULLY!")
    print("="*80)
    print(f"Total Mahasiswa   : {len(data_mahasiswa):,}")
    print(f"Total Dosen       : {len(data_dosen):,}")
    print(f"Total Mata Kuliah : {len(data_mata_kuliah):,}")
    print(f"Total Transaksi   : {len(data_krs):,}")
    print("="*80)
    print("\nOutput Files:")
    print("  1. data_1nf.csv  -> Untuk tabel FLAT (Denormalized)")
    print("  2. data_3nf.sql  -> Untuk tabel NORMALIZED (3NF)")
    print("\nSilakan import file-file tersebut ke MySQL untuk testing!")
    print("="*80)


if __name__ == "__main__":
    main()
