// lib/core/data/service_data.dart

final layananData = {
  "publik": {
    "title": "Layanan Publik",
    "subtitle": "Pelayanan untuk Masyarakat",
    "image": "assets/images/Logo Pelayanan Publik.png",
    "layout": "list",
    "items": [
      { "title": "Pilih Layanan GASPUL", "icon": "assets/images/logo_gaspul.png", "link": "https://gaspul.com/home"},
      { "title": "Ambil Antrian", "icon": "assets/images/Logo Ambil Antrian.png" },
      { "title": "Cek Status Layanan", "icon": "assets/images/Logo Status Layanan.png", "link": "https://gaspul.com/pencarian" },
      { "title": "Statistik Pelayanan", "icon": "assets/images/Logo Statistik Pelayanan.png" },
      { "title": "Layanan Konsultasi", "icon": "assets/images/Logo Layanan Konsultasi.png" },
    ]
  },
  "internal": {
    "title": "Layanan Internal",
    "subtitle": "Sistem Internal Organisasi",
    "image": "assets/images/Logo Layanan Internal.png",
    "layout": "grid",
    "items": [
      {
        "title": "Gembira",
        "icon": "assets/images/Logo Gembira.png",
        "link": "https://gembira.gaspul.com"
      },
      {
        "title": "Sihabba",
        "icon": "assets/images/Logo Sihabba.png",
        "link": "https://sihabba.gaspul.com/admin/login"
      },
      {
        "title": "Bengkel IT",
        "icon": "assets/images/logo Bengkel IT.png",
        "link": "https://bengkel.gaspul.com"
      },
      {
        "title": "SIKEMBAR",
        "icon": "assets/images/Logo SIKEMBAR.png"
      },
      {
        "title": "Cuti",
        "icon": "assets/images/Logo Cuti.png",
      },
      {
        "title": "RKB",
        "icon": "assets/images/Logo RKB.png",
      },
      {
        "title": "BMN Kanwil",
        "icon": "assets/images/logo_gaspul.png",
      },
    ],
  },
"kabupaten": {
  "title": "Layanan Kabupaten",
  "subtitle": "Layanan Tingkat Daerah",
  "image": "assets/images/Logo Layanan Kabupaten.png",
  "layout": "grid",
  "items": [
    {"title": "Majene", "icon": "assets/images/Logo Kabupaten Majene.png"},
    {"title": "Mamasa", "icon": "assets/images/Logo Kabupaten Mamasa.png"},
    {"title": "Mamuju", "icon": "assets/images/Logo Kabupaten Mamuju.png"},
    {"title": "Mamuju Tengah", "icon": "assets/images/Logo Kabupaten Mamuju Tengah.png"},
    {
      "title": "Pasangkayu",
      "icon": "assets/images/Logo Kabupaten Pasangkayu.png",
      "nestedPage": "pasangkayuDetail" // <-- ini untuk page baru
    },
    {"title": "Polewali Mandar", "icon": "assets/images/Logo Kabupaten Polewali Mandar.png"},
  ],
},

// Halaman baru untuk Pasangkayu
"pasangkayuDetail": {
  "title": "Pasangkayu",
  "subtitle": "Layanan Kabupaten Pasangkayu",
  "image": "assets/images/Logo Kabupaten Pasangkayu.png",
  "layout": "grid",
  "items": [
    {
      "title": "KANKEMENAG PASANGKAYU",
      "icon": "assets/images/Logo KEMENAG.png",
      "link": "https://kemenagpasangkayu.id/"
    },
    {
      "title": "DILAYANI SIGA'",
      "icon": "assets/images/Logo KEMENAG.png",
      "nestedPage": "sigaPasangkayu"
    },
  ],
},

// Halaman nested lagi untuk SIGA’ Pasangkayu
"sigaPasangkayu": {
  "title": "DILAYANI SIGA'",
  "subtitle": "Layanan Cuti",
  "image": "assets/images/Logo KEMENAG.png",
  "layout": "grid",
  "items": [
    {
      "title": "Layanan Cuti",
      "icon": "assets/images/Logo Cuti.png",
      "link": "https://kemenagpasangkayu.id/cuti/login"
    },
  ],
},
"pendidikan": {
  "title": "Layanan Pendidikan",
  "subtitle": "Layanan Pendidikan",
  "image": "assets/images/Logo Layanan Pendidikan.png",
  "layout": "grid",
  "items": [
    {
      "title": "SIAGA",
      "icon": "assets/images/Logo SIAGA.png",
      "link": "https://siagapendis.kemenag.go.id/"
    },
    {
      "title": "Emis",
      "icon": "assets/images/Logo Emis.png",
      "link": "https://emis.kemenag.go.id/"
    },
    {
      "title": "Sihabba",
      "icon": "assets/images/Logo Sihabba.png",
      "link": "https://sihabba.gaspul.com/admin/login"
    },
    {
      "title": "SIMPATIKA",
      "icon": "assets/images/Logo SIMPATIKA.png",
      "link": "https://simpatika.kemenag.go.id/"
    },
    {
      "title": "PDUM",
      "icon": "assets/images/Logo PDUM.png",
      "link": "https://pdum.kemenag.go.id/"
    },
    {
      "title": "GTK Madrasah",
      "icon": "assets/images/Logo GTK Madrasah.png",
      "link": "https://emisgtk.kemenag.go.id/"
    },
  ],
},

  "kua": {
    "title": "Layanan KUA",
    "subtitle": "Kantor Urusan Agama",
    "image": "assets/images/Logo KUA.png",
    "layout": "grid",
    "items": [
      {
        "title": "Simkah",
        "icon": "assets/images/logo Simkah.png",
        "link": "https://simkah4.kemenag.go.id/"
      },
    ],
  },
  "rubrik": {
    "title": "Rubrik",
    "subtitle": "Informasi dan Berita",
    "image": "assets/images/Logo Rubrik.png",
    "layout": "grid",
    "items": [
      {
        "title": "Podcast",
        "icon": "assets/images/Logo Podcast.png",
        "link": "https://www.youtube.com/@kanwilkemenagsulbar386/videos"
      },
    ],
  },
  "pengaduan": {
    "title": "Pengaduan",
    "subtitle": "Layanan Pengaduan",
    "image": "assets/images/Logo Pengaduan.png",
    "layout": "grid",
    "items": [
      {
        "title": "Simdumas ITJEN",
        "icon": "assets/images/logo Dumas ITJEN.png",
        "link": "https://simdumas.kemenag.go.id/"
      },
      {
        "title": "LAPOR",
        "icon": "assets/images/logo LAPOR.png",
        "link": "https://prod.lapor.go.id/"
      },
    ],
  },
};
