# Sistem Otomatisasi CFA — Panduan README

Dokumen ini menjelaskan cara kerja *setup* global untuk sistem otomatisasi CFA (Confirmatory Factor Analysis) berbasis R. Semua konfigurasi utama dikendalikan melalui berkas **setup.R**. Anda cukup mengubah isi variabel di dalamnya tanpa pernah menyentuh kode utama.

---
**Buka file `cfa_wlsmv.Rproj` dengan `RStudio`, pada bagian console jalankan program dengan `source("Scripts/main.R")`.**

---

## 1. Berkas Input Data

Sistem membaca satu berkas Excel yang berisi beberapa sheet (misalnya *PRETEST*, *POST TEST*, dll.).

```r
DATA_FILE <- "Data/ANALISIS PRETEST POST TEST.xlsx"
```

Pastikan struktur sheet sudah benar dan konsisten.

---

## 2. Mode Analisis (RUN_MODE)

Mode ini menentukan sheet mana yang akan diproses serta nama laporan akhir.

Nilai yang didukung:

- `PRETEST`
- `POST TEST`

Contoh:

```r
RUN_MODE <- "POST TEST"
```

---

## 3. Pemilihan Tipe Model

Mesin CFA menggunakan hierarki prioritas berikut:

1. **USE_MODEL_FILE = TRUE**  
   → Sistem memuat model dari berkas teks.
2. **USE_EFA = TRUE**  
   → Sistem melakukan EFA untuk menghasilkan struktur model.
3. **USE_MANUAL_MODEL = TRUE**  
   → Sistem menggunakan grup item manual sebagai fallback.

Konfigurasi:

```r
USE_MODEL_FILE <- TRUE
USE_EFA <- TRUE
USE_MANUAL_MODEL <- TRUE
```

Tidak ada konflik antar‑opsi—semuanya sudah diatur dengan prioritas ketat.

---

## 4. Opsi EFA

Digunakan jika `USE_EFA = TRUE` dan tidak ada file model yang ditemukan.

```r
EFA_THRESHOLD <- 0.30
EFA_FACTOR <- 4
```

- `EFA_THRESHOLD` menentukan batas minimal loading.
- `EFA_FACTOR` menetapkan jumlah faktor yang diekstrak.

---

## 5. Tingkat Verbose

Pengaturan untuk menampilkan log proses di konsol.

```r
VERBOSE <- TRUE
```

- `TRUE` → tampilkan semua detail proses.
- `FALSE` → mode senyap.

---

## 6. File Model Otomatis

Berdasarkan RUN_MODE, sistem membuat jalur file otomatis:

```
Models/cfa_pretest_model.txt
Models/cfa_post_test_model.txt
```

Kode:

```r
MODEL_FILE_PATH <- paste0("Models/cfa_", to_snake(RUN_MODE), "_model.txt")
```

Anda bisa meng-override ini, tetapi tidak disarankan.

Baca `README_MODEL.md`.

---

## 7. Laporan Akhir (PDF)

Jika diaktifkan, mesin akan membuat laporan PDF otomatis.

```r
PDF_REPORT <- TRUE
REPORT_TITLE <- paste("Laporan CFA", RUN_MODE)
OUTPUT_FILE  <- sprintf("cfa_%s_wlsmv_report.pdf", to_snake(RUN_MODE))
```

---

## Alur Kerja Sistem

1. Membaca konfigurasi dari `Scripts/setup.R`.
2. Menentukan model sesuai prioritas (file → EFA → manual).
3. Melakukan CFA WLSMV.
4. Menyimpan ringkasan hasil, fit indices, serta grafik.
5. Menghasilkan laporan PDF jika diaktifkan.

---

## Struktur Direktori yang Disarankan

```
/
├── Data/
│   └── ANALISIS PRETEST POST TEST.xlsx
├── Models/
│   ├── cfa_pretest_model.txt
│   └── cfa_post_test_model.txt
├── R/
    └── ...
├── Reports/
│   └── ...
└── Scripts/
    ├── main.R 
    └── setup.R
```

---

## Catatan Penting

- Semua konfigurasi global **diatur hanya melalui Scripts/setup.R**.
- Sistem dirancang agar fleksibel namun deterministik.
- Jika model intensif digunakan berulang, disarankan untuk memakai file model final.

---

## Lisensi

Bebas digunakan, dimodifikasi, atau dikembangkan sesuai kebutuhan analisis Anda.
