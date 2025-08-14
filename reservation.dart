class Reservation {
  final String id;
  final String plate;
  final String? customerId;
  final DateTime startTs;
  final DateTime endTs;
  final String pickupPlace;
  final String dropoffPlace;
  String status; // Bekliyor | Onaylandı | İptal

  Reservation({
    required this.id,
    required this.plate,
    required this.customerId,
    required this.startTs,
    required this.endTs,
    required this.pickupPlace,
    required this.dropoffPlace,
    this.status = 'Bekliyor',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'plate': plate,
    'customerId': customerId,
    'startTs': startTs.toIso8601String(),
    'endTs': endTs.toIso8601String(),
    'pickupPlace': pickupPlace,
    'dropoffPlace': dropoffPlace,
    'status': status,
  };

  static Reservation fromJson(Map<String, dynamic> j) => Reservation(
    id: j['id'],
    plate: j['plate'],
    customerId: j['customerId'],
    startTs: DateTime.parse(j['startTs']),
    endTs: DateTime.parse(j['endTs']),
    pickupPlace: j['pickupPlace'],
    dropoffPlace: j['dropoffPlace'],
    status: j['status'] ?? 'Bekliyor',
  );
}
