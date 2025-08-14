class Customer {
  final String id;
  final String name;
  final String phone;
  final String? tcMasked; // masked store (example)
  final String? licensePhotoPathEnc;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.tcMasked,
    this.licensePhotoPathEnc,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'tcMasked': tcMasked,
    'licensePhotoPathEnc': licensePhotoPathEnc,
  };

  static Customer fromJson(Map<String, dynamic> j) => Customer(
    id: j['id'],
    name: j['name'],
    phone: j['phone'],
    tcMasked: j['tcMasked'],
    licensePhotoPathEnc: j['licensePhotoPathEnc'],
  );
}
