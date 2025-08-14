class Rental {
  final String id;
  final String plate;
  final String customerId;
  final DateTime startTs;
  final DateTime estEndTs;
  DateTime? endTs;
  final int startKm;
  int? endKm;
  final double dailyPriceVatIncl;
  final double deposit;
  final String paymentMethod;
  final bool invoiceAttached;
  final String? invoicePdfPath;
  final String? note;

  Rental({
    required this.id,
    required this.plate,
    required this.customerId,
    required this.startTs,
    required this.estEndTs,
    this.endTs,
    required this.startKm,
    this.endKm,
    required this.dailyPriceVatIncl,
    required this.deposit,
    required this.paymentMethod,
    required this.invoiceAttached,
    this.invoicePdfPath,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'plate': plate,
    'customerId': customerId,
    'startTs': startTs.toIso8601String(),
    'estEndTs': estEndTs.toIso8601String(),
    'endTs': endTs?.toIso8601String(),
    'startKm': startKm,
    'endKm': endKm,
    'dailyPriceVatIncl': dailyPriceVatIncl,
    'deposit': deposit,
    'paymentMethod': paymentMethod,
    'invoiceAttached': invoiceAttached,
    'invoicePdfPath': invoicePdfPath,
    'note': note,
  };

  static Rental fromJson(Map<String, dynamic> j) => Rental(
    id: j['id'],
    plate: j['plate'],
    customerId: j['customerId'],
    startTs: DateTime.parse(j['startTs']),
    estEndTs: DateTime.parse(j['estEndTs']),
    endTs: j['endTs'] != null ? DateTime.parse(j['endTs']) : null,
    startKm: j['startKm'],
    endKm: j['endKm'],
    dailyPriceVatIncl: (j['dailyPriceVatIncl'] as num).toDouble(),
    deposit: (j['deposit'] as num).toDouble(),
    paymentMethod: j['paymentMethod'],
    invoiceAttached: j['invoiceAttached'] == true,
    invoicePdfPath: j['invoicePdfPath'],
    note: j['note'],
  );
}
