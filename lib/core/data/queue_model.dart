// gaspul\lib\core\data\queue_model.dart

class Antrian {
  final int id;
  final String nomor;
  final String nama;
  final String bidang;
  final String layanan;
  final String tanggal;
  final String qrCode;

  Antrian({
    required this.id,
    required this.nomor,
    required this.nama,
    required this.bidang,
    required this.layanan,
    required this.tanggal,
    required this.qrCode,
  });

  factory Antrian.fromJson(Map<String, dynamic> json) => Antrian(
        id: json['id'],
        nomor: json['nomor'],
        nama: json['nama'],
        bidang: json['bidang'],
        layanan: json['layanan'],
        tanggal: json['tanggal'],
        qrCode: json['qr_code'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nomor': nomor,
        'nama': nama,
        'bidang': bidang,
        'layanan': layanan,
        'tanggal': tanggal,
        'qr_code': qrCode,
      };
}
