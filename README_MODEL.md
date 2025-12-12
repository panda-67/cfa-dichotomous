# 🔧 Bagaimana Model Dibuat (Dari EFA → Refinement Manual → CFA Final)

Proses pembangunan model dilakukan secara bertingkat, menjaga agar struktur faktor tidak lahir dari “tebak-tebakan”, tetapi juga tidak membiarkan algoritma menentukan segalanya. Intuisinya: EFA memberi peta, manusia memberi arah.

## 0) Apa itu EFA (Exploratory Factor Analysis) — Penjelasan Teknis Singkat

EFA adalah metode statistik untuk mengidentifikasi jumlah faktor laten dan menentukan item mana memuat pada faktor mana tanpa model awal. Algoritma EFA menganalisis matriks korelasi dan mengekstrak struktur yang paling menjelaskan varians bersama (common variance) antar item.

## 1) EFA sebagai Pemandu Awal

Jika jSE_EFA = TRUE, sistem akan menjalankan EFA dengan jumlah faktor (EFA_FACTOR) dan threshold (EFA_THRESHOLD) yang ditentukan.

EFA bertugas:

- Memetakan item ke faktor berdasarkan loading tertinggi

- Mengeliminasi item yang loading-nya di bawah threshold

- Menghasilkan “draf struktur faktor” yang layak diuji pada CFA

- Menyimpan template model (cfa_<run_mode>_model.txt) AUTOMATIS bila file belum ada

- Model EFA bukan final — ini hanya titik mula yang logis.

## 2) Pemeriksaan Struktur: apakah masuk akal secara substantif?

Setelah template EFA keluar, peneliti harus menilai:

- Apakah item dalam satu faktor memang sekeluarga makna?

- Ada item “nyasar”?

- Ada faktor yang perlu digabung/dipisah?

- Ada item ambivalen (double-loading)?

Ini tahap krusial, karena statistik hanya melihat angka — manusia melihat makna.

## 3) Revisi Manual (Human-Guided Model Refinement)

Jika perlu, file model hasil EFA diedit:

- memindahkan item ke faktor lain

- memecah faktor yang terlalu besar

- menghapus item yang tidak konsisten secara teoretis

- memberi nama faktor yang lebih tepat

Revisi manual ini dilakukan pada file:

`Models/cfa_<run_mode>_model.txt`


Sistem akan menggunakan file ini saat:

`USE_MODEL_FILE = TRUE`


Jika file ada → file menang (paling tinggi prioritas)
Jika file tidak ada → sistem membuat template baru dengan EFA (jika EFA ON)

## 4) CFA Final: menguji apakah struktur yang telah diperhalus “berdiri tegak”

Model yang sudah direvisi akan diuji dengan WLSMV atau estimator lain.

Output yang dinilai:

- CFI/TLI (scaled) → > 0.95 ideal

- RMSEA (scaled) → < 0.06 ideal

- SRMR → < 0.08 ideal

- Modifikasi Indeks → mendeteksi residual hubungan item yang terlalu kuat

Jika masih ada masalah, kembali ke langkah 2–3.
Model ideal lahir dari iterasi — bukan sekali jalan.

## 5) Model Final → Disimpan → Dipakai untuk Report

Setelah struktur stabil:

- file final model disimpan

- CFA dijalankan

- PDF report otomatis dihasilkan melalui R Markdown

- seluruh pipeline tinggal DIEKSEKUSI dengan satu tombol

Ini menjadikan analisis CFA konsisten, replikatif, dan bebas kesalahan manual.

