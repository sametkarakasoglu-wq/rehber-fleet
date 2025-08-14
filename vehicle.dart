class Vehicle {
  final String plate;
  final String make;
  final String model;
  final String clazz; // sınıf
  final double dailyPriceVatIncl; // günlük KDV dahil
  final double monthlyPriceNet;   // aylık net
  final double monthlyVatRate;    // aylık KDV oranı (örn. 0.20)
  String status; // 'müsait' | 'kirada' | 'serviste'

  Vehicle({
    required this.plate,
    required this.make,
    required this.model,
    required this.clazz,
    required this.dailyPriceVatIncl,
    required this.monthlyPriceNet,
    required this.monthlyVatRate,
    this.status = 'müsait',
  });

  Map<String, dynamic> toJson() => {
    'plate': plate,
    'make': make,
    'model': model,
    'clazz': clazz,
    'dailyPriceVatIncl': dailyPriceVatIncl,
    'monthlyPriceNet': monthlyPriceNet,
    'monthlyVatRate': monthlyVatRate,
    'status': status,
  };

  static Vehicle fromJson(Map<String, dynamic> j) => Vehicle(
    plate: j['plate'],
    make: j['make'],
    model: j['model'],
    clazz: j['clazz'],
    dailyPriceVatIncl: (j['dailyPriceVatIncl'] as num).toDouble(),
    monthlyPriceNet: (j['monthlyPriceNet'] as num).toDouble(),
    monthlyVatRate: (j['monthlyVatRate'] as num).toDouble(),
    status: j['status'] ?? 'müsait',
  );
}
