-- ============================================================
-- DATABASE: Sistem Pemesanan Digital & Aplikasi Kasir
-- Kedai Kopi Mbah Buyut
-- ============================================================
-- Deskripsi : Sistem terintegrasi pemesanan QR Code + kasir
--             berbasis web untuk UMKM kuliner
-- Author    : Tim Pengembang
-- Versi     : 1.0
-- DBMS      : MySQL 8.0+
-- ============================================================

-- Buat database
CREATE DATABASE IF NOT EXISTS kedai_kopi_mbah_buyut
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE kedai_kopi_mbah_buyut;

-- ============================================================
-- 1. TABEL ROLES (Peran Pengguna)
-- ============================================================
-- Menyimpan data peran pengguna: admin, kasir, pelanggan
CREATE TABLE roles (
    id          INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    nama_role   VARCHAR(50)     NOT NULL UNIQUE
                                COMMENT 'Nama peran: admin, kasir, pelanggan',
    deskripsi   TEXT            NULL
                                COMMENT 'Deskripsi hak akses peran',
    created_at  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='Tabel peran pengguna sistem';

-- ============================================================
-- 2. TABEL USERS (Pengguna)
-- ============================================================
-- Menyimpan data pengguna (admin, kasir, pelanggan)
CREATE TABLE users (
    id              INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    role_id         INT UNSIGNED    NOT NULL
                                    COMMENT 'FK ke tabel roles',
    nama            VARCHAR(100)    NOT NULL
                                    COMMENT 'Nama lengkap pengguna',
    email           VARCHAR(150)    NOT NULL UNIQUE
                                    COMMENT 'Email untuk login',
    password        VARCHAR(255)    NOT NULL
                                    COMMENT 'Password terenkripsi (bcrypt)',
    no_telepon      VARCHAR(20)     NULL
                                    COMMENT 'Nomor telepon pengguna',
    alamat          TEXT            NULL
                                    COMMENT 'Alamat pengguna',
    foto_profil     VARCHAR(255)    NULL
                                    COMMENT 'Path file foto profil',
    saldo_coin      INT UNSIGNED    NOT NULL DEFAULT 0
                                    COMMENT 'Saldo coin loyalitas pelanggan',
    status          ENUM('aktif', 'nonaktif')
                                    NOT NULL DEFAULT 'aktif'
                                    COMMENT 'Status akun pengguna',
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_users_role
        FOREIGN KEY (role_id) REFERENCES roles(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    INDEX idx_users_email (email),
    INDEX idx_users_role (role_id),
    INDEX idx_users_status (status)
) ENGINE=InnoDB COMMENT='Tabel data pengguna sistem';

-- ============================================================
-- 3. TABEL KATEGORI_MENU (Kategori Menu)
-- ============================================================
-- Menyimpan kategori menu (Kopi, Non-Kopi, Makanan, dll.)
CREATE TABLE kategori_menu (
    id              INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    nama_kategori   VARCHAR(100)    NOT NULL UNIQUE
                                    COMMENT 'Nama kategori menu',
    deskripsi       TEXT            NULL
                                    COMMENT 'Deskripsi kategori',
    status          ENUM('aktif', 'nonaktif')
                                    NOT NULL DEFAULT 'aktif'
                                    COMMENT 'Status kategori',
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='Tabel kategori menu';

-- ============================================================
-- 4. TABEL MENU (Data Menu)
-- ============================================================
-- Menyimpan data menu yang tersedia di kedai kopi
CREATE TABLE menu (
    id              INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    kategori_id     INT UNSIGNED    NOT NULL
                                    COMMENT 'FK ke tabel kategori_menu',
    nama_menu       VARCHAR(150)    NOT NULL
                                    COMMENT 'Nama menu',
    deskripsi       TEXT            NULL
                                    COMMENT 'Deskripsi menu',
    gambar          VARCHAR(255)    NULL
                                    COMMENT 'Path file gambar menu',
    status          ENUM('tersedia', 'habis', 'nonaktif')
                                    NOT NULL DEFAULT 'tersedia'
                                    COMMENT 'Status ketersediaan menu',
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_menu_kategori
        FOREIGN KEY (kategori_id) REFERENCES kategori_menu(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    INDEX idx_menu_kategori (kategori_id),
    INDEX idx_menu_status (status)
) ENGINE=InnoDB COMMENT='Tabel data menu';

-- ============================================================
-- 5. TABEL VARIAN_MENU (Varian Menu)
-- ============================================================
-- Menyimpan varian menu (Hot, Iced, Small, Regular, Large, dll.)
CREATE TABLE varian_menu (
    id              INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    menu_id         INT UNSIGNED    NOT NULL
                                    COMMENT 'FK ke tabel menu',
    nama_varian     VARCHAR(100)    NOT NULL
                                    COMMENT 'Nama varian (Hot, Iced, Small, Large, dll.)',
    harga           DECIMAL(12,2)   NOT NULL DEFAULT 0.00
                                    COMMENT 'Harga varian dalam Rupiah',
    status          ENUM('tersedia', 'habis', 'nonaktif')
                                    NOT NULL DEFAULT 'tersedia'
                                    COMMENT 'Status ketersediaan varian',
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_varian_menu
        FOREIGN KEY (menu_id) REFERENCES menu(id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    UNIQUE KEY uk_menu_varian (menu_id, nama_varian),
    INDEX idx_varian_menu (menu_id),
    INDEX idx_varian_status (status)
) ENGINE=InnoDB COMMENT='Tabel varian menu beserta harga';

-- ============================================================
-- 6. TABEL MEJA (Data Meja)
-- ============================================================
-- Menyimpan data meja dan QR Code yang terhubung
CREATE TABLE meja (
    id              INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    nomor_meja      VARCHAR(10)     NOT NULL UNIQUE
                                    COMMENT 'Nomor identifikasi meja',
    qr_code         VARCHAR(255)    NOT NULL UNIQUE
                                    COMMENT 'Kode unik QR Code untuk meja',
    kapasitas       INT UNSIGNED    NULL DEFAULT 4
                                    COMMENT 'Kapasitas kursi per meja',
    status          ENUM('tersedia', 'terisi', 'nonaktif')
                                    NOT NULL DEFAULT 'tersedia'
                                    COMMENT 'Status ketersediaan meja',
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='Tabel data meja dan QR Code';

-- ============================================================
-- 7. TABEL METODE_PEMBAYARAN (Metode Pembayaran)
-- ============================================================
-- Menyimpan metode pembayaran yang didukung (tunai, non-tunai)
CREATE TABLE metode_pembayaran (
    id              INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    nama_metode     VARCHAR(100)    NOT NULL UNIQUE
                                    COMMENT 'Nama metode pembayaran',
    jenis           ENUM('tunai', 'non_tunai')
                                    NOT NULL
                                    COMMENT 'Jenis: tunai atau non-tunai',
    logo            VARCHAR(255)    NULL
                                    COMMENT 'Path file logo metode pembayaran',
    status          ENUM('aktif', 'nonaktif')
                                    NOT NULL DEFAULT 'aktif'
                                    COMMENT 'Status metode pembayaran',
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='Tabel metode pembayaran';

-- ============================================================
-- 8. TABEL PESANAN (Data Pesanan)
-- ============================================================
-- Menyimpan data pesanan dari pelanggan
CREATE TABLE pesanan (
    id                  INT UNSIGNED        AUTO_INCREMENT PRIMARY KEY,
    nomor_pesanan       VARCHAR(30)         NOT NULL UNIQUE
                                            COMMENT 'Nomor unik pesanan (auto-generated)',
    pelanggan_id        INT UNSIGNED        NULL
                                            COMMENT 'FK ke tabel users (pelanggan)',
    kasir_id            INT UNSIGNED        NULL
                                            COMMENT 'FK ke tabel users (kasir yang memproses)',
    meja_id             INT UNSIGNED        NULL
                                            COMMENT 'FK ke tabel meja (jika dine-in)',
    metode_pembayaran_id INT UNSIGNED       NULL
                                            COMMENT 'FK ke tabel metode_pembayaran',
    jenis_pesanan       ENUM('dine_in', 'take_away')
                                            NOT NULL DEFAULT 'dine_in'
                                            COMMENT 'Jenis pesanan',
    catatan             TEXT                NULL
                                            COMMENT 'Catatan tambahan pesanan',
    status              ENUM('menunggu', 'diproses', 'selesai', 'ditolak', 'dibatalkan')
                                            NOT NULL DEFAULT 'menunggu'
                                            COMMENT 'Status pesanan',
    total_harga         DECIMAL(12,2)       NOT NULL DEFAULT 0.00
                                            COMMENT 'Total harga sebelum diskon',
    diskon_coin         DECIMAL(12,2)       NOT NULL DEFAULT 0.00
                                            COMMENT 'Potongan harga dari penukaran coin',
    total_bayar         DECIMAL(12,2)       NOT NULL DEFAULT 0.00
                                            COMMENT 'Total yang harus dibayar (setelah diskon)',
    sumber_pesanan      ENUM('qr_code', 'manual')
                                            NOT NULL DEFAULT 'qr_code'
                                            COMMENT 'Sumber pesanan: QR Code atau input manual kasir',
    waktu_konfirmasi    TIMESTAMP           NULL
                                            COMMENT 'Waktu pesanan dikonfirmasi kasir',
    created_at          TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_pesanan_pelanggan
        FOREIGN KEY (pelanggan_id) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL,

    CONSTRAINT fk_pesanan_kasir
        FOREIGN KEY (kasir_id) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL,

    CONSTRAINT fk_pesanan_meja
        FOREIGN KEY (meja_id) REFERENCES meja(id)
        ON UPDATE CASCADE ON DELETE SET NULL,

    CONSTRAINT fk_pesanan_metode_bayar
        FOREIGN KEY (metode_pembayaran_id) REFERENCES metode_pembayaran(id)
        ON UPDATE CASCADE ON DELETE SET NULL,

    INDEX idx_pesanan_pelanggan (pelanggan_id),
    INDEX idx_pesanan_kasir (kasir_id),
    INDEX idx_pesanan_status (status),
    INDEX idx_pesanan_tanggal (created_at),
    INDEX idx_pesanan_nomor (nomor_pesanan)
) ENGINE=InnoDB COMMENT='Tabel data pesanan';

-- ============================================================
-- 9. TABEL DETAIL_PESANAN (Detail Item Pesanan)
-- ============================================================
-- Menyimpan detail item dalam setiap pesanan
CREATE TABLE detail_pesanan (
    id              INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    pesanan_id      INT UNSIGNED    NOT NULL
                                    COMMENT 'FK ke tabel pesanan',
    varian_menu_id  INT UNSIGNED    NOT NULL
                                    COMMENT 'FK ke tabel varian_menu',
    jumlah          INT UNSIGNED    NOT NULL DEFAULT 1
                                    COMMENT 'Jumlah item yang dipesan',
    harga_satuan    DECIMAL(12,2)   NOT NULL
                                    COMMENT 'Harga satuan saat pemesanan',
    subtotal        DECIMAL(12,2)   NOT NULL
                                    COMMENT 'Subtotal = jumlah x harga_satuan',
    catatan_item    TEXT            NULL
                                    COMMENT 'Catatan khusus per item',
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_detail_pesanan
        FOREIGN KEY (pesanan_id) REFERENCES pesanan(id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_detail_varian
        FOREIGN KEY (varian_menu_id) REFERENCES varian_menu(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    INDEX idx_detail_pesanan (pesanan_id),
    INDEX idx_detail_varian (varian_menu_id)
) ENGINE=InnoDB COMMENT='Tabel detail item pesanan';

-- ============================================================
-- 10. TABEL TRANSAKSI (Data Transaksi Pembayaran)
-- ============================================================
-- Menyimpan data transaksi pembayaran yang telah selesai
CREATE TABLE transaksi (
    id                  INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    nomor_transaksi     VARCHAR(30)     NOT NULL UNIQUE
                                        COMMENT 'Nomor unik transaksi',
    pesanan_id          INT UNSIGNED    NOT NULL UNIQUE
                                        COMMENT 'FK ke tabel pesanan (1:1)',
    kasir_id            INT UNSIGNED    NULL
                                        COMMENT 'FK ke tabel users (kasir)',
    metode_pembayaran_id INT UNSIGNED   NULL
                                        COMMENT 'FK ke tabel metode_pembayaran',
    total_bayar         DECIMAL(12,2)   NOT NULL
                                        COMMENT 'Total pembayaran',
    jumlah_dibayar      DECIMAL(12,2)   NOT NULL DEFAULT 0.00
                                        COMMENT 'Jumlah uang yang dibayarkan',
    kembalian           DECIMAL(12,2)   NOT NULL DEFAULT 0.00
                                        COMMENT 'Jumlah kembalian (tunai)',
    status_pembayaran   ENUM('berhasil', 'gagal', 'pending')
                                        NOT NULL DEFAULT 'pending'
                                        COMMENT 'Status pembayaran',
    waktu_pembayaran    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
                                        COMMENT 'Waktu pembayaran dilakukan',
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_transaksi_pesanan
        FOREIGN KEY (pesanan_id) REFERENCES pesanan(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT fk_transaksi_kasir
        FOREIGN KEY (kasir_id) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE SET NULL,

    CONSTRAINT fk_transaksi_metode
        FOREIGN KEY (metode_pembayaran_id) REFERENCES metode_pembayaran(id)
        ON UPDATE CASCADE ON DELETE SET NULL,

    INDEX idx_transaksi_pesanan (pesanan_id),
    INDEX idx_transaksi_kasir (kasir_id),
    INDEX idx_transaksi_tanggal (waktu_pembayaran),
    INDEX idx_transaksi_status (status_pembayaran)
) ENGINE=InnoDB COMMENT='Tabel data transaksi pembayaran';

-- ============================================================
-- 11. TABEL KERANJANG (Keranjang Belanja Pelanggan)
-- ============================================================
-- Menyimpan data keranjang belanja sementara pelanggan
CREATE TABLE keranjang (
    id              INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    user_id         INT UNSIGNED    NOT NULL
                                    COMMENT 'FK ke tabel users (pelanggan)',
    varian_menu_id  INT UNSIGNED    NOT NULL
                                    COMMENT 'FK ke tabel varian_menu',
    jumlah          INT UNSIGNED    NOT NULL DEFAULT 1
                                    COMMENT 'Jumlah item dalam keranjang',
    catatan_item    TEXT            NULL
                                    COMMENT 'Catatan khusus per item',
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_keranjang_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_keranjang_varian
        FOREIGN KEY (varian_menu_id) REFERENCES varian_menu(id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    UNIQUE KEY uk_keranjang_item (user_id, varian_menu_id),
    INDEX idx_keranjang_user (user_id)
) ENGINE=InnoDB COMMENT='Tabel keranjang belanja pelanggan';

-- ============================================================
-- 12. TABEL RIWAYAT_COIN (Riwayat Coin Loyalitas)
-- ============================================================
-- Mencatat riwayat perolehan dan penukaran coin pelanggan
CREATE TABLE riwayat_coin (
    id              INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    user_id         INT UNSIGNED    NOT NULL
                                    COMMENT 'FK ke tabel users (pelanggan)',
    pesanan_id      INT UNSIGNED    NULL
                                    COMMENT 'FK ke tabel pesanan (opsional)',
    jumlah_coin     INT             NOT NULL
                                    COMMENT 'Jumlah coin (positif = masuk, negatif = keluar)',
    tipe            ENUM('masuk', 'keluar')
                                    NOT NULL
                                    COMMENT 'Tipe transaksi coin',
    keterangan      VARCHAR(255)    NULL
                                    COMMENT 'Keterangan transaksi coin',
    saldo_sebelum   INT UNSIGNED    NOT NULL DEFAULT 0
                                    COMMENT 'Saldo coin sebelum transaksi',
    saldo_sesudah   INT UNSIGNED    NOT NULL DEFAULT 0
                                    COMMENT 'Saldo coin sesudah transaksi',
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_riwayat_coin_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT fk_riwayat_coin_pesanan
        FOREIGN KEY (pesanan_id) REFERENCES pesanan(id)
        ON UPDATE CASCADE ON DELETE SET NULL,

    INDEX idx_riwayat_coin_user (user_id),
    INDEX idx_riwayat_coin_tipe (tipe),
    INDEX idx_riwayat_coin_tanggal (created_at)
) ENGINE=InnoDB COMMENT='Tabel riwayat coin loyalitas pelanggan';

-- ============================================================
-- 13. TABEL JAM_OPERASIONAL (Jam Operasional Kedai)
-- ============================================================
-- Menyimpan pengaturan jam operasional per hari
CREATE TABLE jam_operasional (
    id              INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    hari            ENUM('Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu')
                                    NOT NULL UNIQUE
                                    COMMENT 'Hari operasional',
    jam_buka        TIME            NOT NULL
                                    COMMENT 'Jam buka kedai',
    jam_tutup       TIME            NOT NULL
                                    COMMENT 'Jam tutup kedai',
    status          ENUM('buka', 'tutup')
                                    NOT NULL DEFAULT 'buka'
                                    COMMENT 'Status operasional hari tersebut',
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='Tabel jam operasional kedai';

-- ============================================================
-- 14. TABEL PENGATURAN_COIN (Konfigurasi Coin Loyalitas)
-- ============================================================
-- Menyimpan konfigurasi konversi coin
CREATE TABLE pengaturan_coin (
    id                      INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    min_transaksi           DECIMAL(12,2)   NOT NULL DEFAULT 0.00
                                            COMMENT 'Minimum nominal transaksi untuk mendapat coin',
    coin_per_transaksi      INT UNSIGNED    NOT NULL DEFAULT 1
                                            COMMENT 'Jumlah coin yang didapat per transaksi',
    nilai_tukar_coin        DECIMAL(12,2)   NOT NULL DEFAULT 1000.00
                                            COMMENT 'Nilai tukar 1 coin ke Rupiah',
    min_coin_tukar          INT UNSIGNED    NOT NULL DEFAULT 10
                                            COMMENT 'Minimum coin untuk penukaran',
    status                  ENUM('aktif', 'nonaktif')
                                            NOT NULL DEFAULT 'aktif',
    created_at              TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='Tabel konfigurasi coin loyalitas';


-- ============================================================
-- DATA AWAL (SEED DATA)
-- ============================================================

-- Insert data roles
INSERT INTO roles (nama_role, deskripsi) VALUES
    ('admin',       'Administrator sistem dengan akses penuh'),
    ('kasir',       'Kasir yang memproses transaksi dan pesanan'),
    ('pelanggan',   'Pelanggan yang melakukan pemesanan');

-- Insert data admin default (password: admin123 → bcrypt hash)
INSERT INTO users (role_id, nama, email, password, status) VALUES
    (1, 'Admin Kedai', 'admin@kedaikopi.com',
     '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'aktif');

-- Insert data kasir default (password: kasir123 → bcrypt hash)
INSERT INTO users (role_id, nama, email, password, status) VALUES
    (2, 'Kasir 1', 'kasir1@kedaikopi.com',
     '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
     'aktif');

-- Insert data metode pembayaran
INSERT INTO metode_pembayaran (nama_metode, jenis, status) VALUES
    ('Tunai',           'tunai',        'aktif'),
    ('QRIS',            'non_tunai',    'aktif'),
    ('Transfer Bank',   'non_tunai',    'aktif'),
    ('OVO',             'non_tunai',    'aktif'),
    ('GoPay',           'non_tunai',    'aktif'),
    ('Dana',            'non_tunai',    'aktif');

-- Insert data jam operasional
INSERT INTO jam_operasional (hari, jam_buka, jam_tutup, status) VALUES
    ('Senin',   '08:00:00', '22:00:00', 'buka'),
    ('Selasa',  '08:00:00', '22:00:00', 'buka'),
    ('Rabu',    '08:00:00', '22:00:00', 'buka'),
    ('Kamis',   '08:00:00', '22:00:00', 'buka'),
    ('Jumat',   '08:00:00', '23:00:00', 'buka'),
    ('Sabtu',   '09:00:00', '23:00:00', 'buka'),
    ('Minggu',  '09:00:00', '22:00:00', 'buka');

-- Insert data pengaturan coin
INSERT INTO pengaturan_coin (min_transaksi, coin_per_transaksi, nilai_tukar_coin, min_coin_tukar, status) VALUES
    (20000.00, 1, 1000.00, 10, 'aktif');

-- Insert kategori menu contoh
INSERT INTO kategori_menu (nama_kategori, deskripsi, status) VALUES
    ('Kopi',            'Berbagai jenis minuman kopi',      'aktif'),
    ('Non-Kopi',        'Minuman selain kopi',              'aktif'),
    ('Makanan Ringan',  'Snack dan makanan ringan',         'aktif'),
    ('Makanan Berat',   'Menu makanan berat',               'aktif');

-- Insert menu contoh
INSERT INTO menu (kategori_id, nama_menu, deskripsi, status) VALUES
    (1, 'Espresso',         'Kopi espresso shot',                   'tersedia'),
    (1, 'Americano',        'Espresso dengan air panas',            'tersedia'),
    (1, 'Cappuccino',       'Espresso dengan susu foam',            'tersedia'),
    (1, 'Caffe Latte',      'Espresso dengan susu steamed',         'tersedia'),
    (1, 'Kopi Susu Gula Aren', 'Kopi susu dengan gula aren',       'tersedia'),
    (2, 'Matcha Latte',     'Teh hijau matcha dengan susu',         'tersedia'),
    (2, 'Coklat Panas',     'Minuman coklat hangat',                'tersedia'),
    (2, 'Jus Jeruk',        'Jus jeruk segar',                     'tersedia'),
    (3, 'Kentang Goreng',   'French fries crispy',                  'tersedia'),
    (3, 'Roti Bakar',       'Roti bakar dengan selai',              'tersedia'),
    (4, 'Nasi Goreng',      'Nasi goreng spesial kedai',            'tersedia'),
    (4, 'Mie Goreng',       'Mie goreng spesial kedai',             'tersedia');

-- Insert varian menu contoh
INSERT INTO varian_menu (menu_id, nama_varian, harga, status) VALUES
    -- Espresso
    (1, 'Single Shot',      15000.00,   'tersedia'),
    (1, 'Double Shot',      20000.00,   'tersedia'),
    -- Americano
    (2, 'Hot',              18000.00,   'tersedia'),
    (2, 'Iced',             20000.00,   'tersedia'),
    -- Cappuccino
    (3, 'Hot',              22000.00,   'tersedia'),
    (3, 'Iced',             25000.00,   'tersedia'),
    -- Caffe Latte
    (4, 'Hot',              22000.00,   'tersedia'),
    (4, 'Iced',             25000.00,   'tersedia'),
    -- Kopi Susu Gula Aren
    (5, 'Regular',          18000.00,   'tersedia'),
    (5, 'Large',            23000.00,   'tersedia'),
    -- Matcha Latte
    (6, 'Hot',              25000.00,   'tersedia'),
    (6, 'Iced',             28000.00,   'tersedia'),
    -- Coklat Panas
    (7, 'Regular',          20000.00,   'tersedia'),
    -- Jus Jeruk
    (8, 'Regular',          15000.00,   'tersedia'),
    (8, 'Large',            20000.00,   'tersedia'),
    -- Kentang Goreng
    (9, 'Regular',          15000.00,   'tersedia'),
    (9, 'Large',            20000.00,   'tersedia'),
    -- Roti Bakar
    (10, 'Coklat',          12000.00,   'tersedia'),
    (10, 'Keju',            15000.00,   'tersedia'),
    (10, 'Coklat Keju',     18000.00,   'tersedia'),
    -- Nasi Goreng
    (11, 'Regular',         25000.00,   'tersedia'),
    (11, 'Spesial',         30000.00,   'tersedia'),
    -- Mie Goreng
    (12, 'Regular',         22000.00,   'tersedia'),
    (12, 'Spesial',         27000.00,   'tersedia');

-- Insert data meja contoh
INSERT INTO meja (nomor_meja, qr_code, kapasitas, status) VALUES
    ('M01',  'QR-MEJA-001-MBAHBUYUT',  4,  'tersedia'),
    ('M02',  'QR-MEJA-002-MBAHBUYUT',  4,  'tersedia'),
    ('M03',  'QR-MEJA-003-MBAHBUYUT',  2,  'tersedia'),
    ('M04',  'QR-MEJA-004-MBAHBUYUT',  2,  'tersedia'),
    ('M05',  'QR-MEJA-005-MBAHBUYUT',  6,  'tersedia'),
    ('M06',  'QR-MEJA-006-MBAHBUYUT',  6,  'tersedia'),
    ('M07',  'QR-MEJA-007-MBAHBUYUT',  4,  'tersedia'),
    ('M08',  'QR-MEJA-008-MBAHBUYUT',  4,  'tersedia'),
    ('M09',  'QR-MEJA-009-MBAHBUYUT',  2,  'tersedia'),
    ('M10',  'QR-MEJA-010-MBAHBUYUT',  8,  'tersedia');


-- ============================================================
-- VIEWS (Untuk Laporan dan Statistik)
-- ============================================================

-- View: Laporan Penjualan Harian
CREATE OR REPLACE VIEW v_laporan_penjualan_harian AS
SELECT
    DATE(t.waktu_pembayaran)            AS tanggal,
    COUNT(t.id)                         AS jumlah_transaksi,
    SUM(t.total_bayar)                  AS total_pendapatan,
    AVG(t.total_bayar)                  AS rata_rata_transaksi,
    mp.nama_metode                      AS metode_pembayaran
FROM transaksi t
LEFT JOIN metode_pembayaran mp ON t.metode_pembayaran_id = mp.id
WHERE t.status_pembayaran = 'berhasil'
GROUP BY DATE(t.waktu_pembayaran), mp.nama_metode
ORDER BY tanggal DESC;

-- View: Menu Terlaris
CREATE OR REPLACE VIEW v_menu_terlaris AS
SELECT
    m.id                                AS menu_id,
    m.nama_menu,
    km.nama_kategori,
    vm.nama_varian,
    SUM(dp.jumlah)                      AS total_terjual,
    SUM(dp.subtotal)                    AS total_pendapatan
FROM detail_pesanan dp
JOIN varian_menu vm ON dp.varian_menu_id = vm.id
JOIN menu m ON vm.menu_id = m.id
JOIN kategori_menu km ON m.kategori_id = km.id
JOIN pesanan p ON dp.pesanan_id = p.id
WHERE p.status = 'selesai'
GROUP BY m.id, m.nama_menu, km.nama_kategori, vm.nama_varian
ORDER BY total_terjual DESC;

-- View: Statistik Transaksi
CREATE OR REPLACE VIEW v_statistik_transaksi AS
SELECT
    COUNT(CASE WHEN status = 'selesai' THEN 1 END)         AS pesanan_selesai,
    COUNT(CASE WHEN status = 'menunggu' THEN 1 END)        AS pesanan_menunggu,
    COUNT(CASE WHEN status = 'diproses' THEN 1 END)        AS pesanan_diproses,
    COUNT(CASE WHEN status = 'ditolak' THEN 1 END)         AS pesanan_ditolak,
    COUNT(CASE WHEN status = 'dibatalkan' THEN 1 END)      AS pesanan_dibatalkan,
    COUNT(*)                                                AS total_pesanan
FROM pesanan;

-- View: Riwayat Transaksi Lengkap
CREATE OR REPLACE VIEW v_riwayat_transaksi AS
SELECT
    t.nomor_transaksi,
    p.nomor_pesanan,
    u_pelanggan.nama                    AS nama_pelanggan,
    u_kasir.nama                        AS nama_kasir,
    p.jenis_pesanan,
    mj.nomor_meja,
    p.total_harga,
    p.diskon_coin,
    t.total_bayar,
    mp.nama_metode                      AS metode_pembayaran,
    t.status_pembayaran,
    t.waktu_pembayaran
FROM transaksi t
JOIN pesanan p ON t.pesanan_id = p.id
LEFT JOIN users u_pelanggan ON p.pelanggan_id = u_pelanggan.id
LEFT JOIN users u_kasir ON t.kasir_id = u_kasir.id
LEFT JOIN meja mj ON p.meja_id = mj.id
LEFT JOIN metode_pembayaran mp ON t.metode_pembayaran_id = mp.id
ORDER BY t.waktu_pembayaran DESC;


-- ============================================================
-- AKHIR SKRIP SQL
-- ============================================================
