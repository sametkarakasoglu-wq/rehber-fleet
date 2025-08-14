import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FleetStore {
  static const _kVehicles = 'vehicles';
  static const _kCustomers = 'customers';
  static const _kRentals = 'rentals';
  static const _kReservations = 'reservations';

  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  // Generic helpers
  static Future<List<Map<String, dynamic>>> _getList(String key) async {
    final p = await _prefs();
    final raw = p.getString(key);
    if (raw == null) return [];
    final List l = jsonDecode(raw);
    return l.cast<Map<String, dynamic>>();
  }

  static Future<void> _setList(String key, List<Map<String, dynamic>> data) async {
    final p = await _prefs();
    await p.setString(key, jsonEncode(data));
  }

  // Vehicles
  static Future<List<Map<String, dynamic>>> vehicles() => _getList(_kVehicles);
  static Future<void> setVehicles(List<Map<String, dynamic>> data) => _setList(_kVehicles, data);

  // Rentals
  static Future<List<Map<String, dynamic>>> rentals() => _getList(_kRentals);
  static Future<void> setRentals(List<Map<String, dynamic>> data) => _setList(_kRentals, data);

  // Reservations
  static Future<List<Map<String, dynamic>>> reservations() => _getList(_kReservations);
  static Future<void> setReservations(List<Map<String, dynamic>> data) => _setList(_kReservations, data);
}

class FleetOps {
  // Add rental
  static Future<void> addRental(Map<String, dynamic> rental) async {
    final list = await FleetStore.rentals();
    list.add(rental);
    await FleetStore.setRentals(list);
  }

  // Complete rental (check-in)
  static Future<void> completeRental(String id, Map<String, dynamic> updates) async {
    final list = await FleetStore.rentals();
    final idx = list.indexWhere((e) => e['id'] == id);
    if (idx >= 0) {
      list[idx].addAll(updates);
      await FleetStore.setRentals(list);
    }
  }

  // Rentals ending in exactly 3 days (local time approximation)
  static Future<List<Map<String, dynamic>>> approachingReturns3Days() async {
    final list = await FleetStore.rentals();
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day).add(const Duration(days: 3));
    List<Map<String, dynamic>> out = [];
    for (final r in list) {
      final est = DateTime.tryParse(r['estEndTs'] ?? '') ?? DateTime.now();
      final dEst = DateTime(est.year, est.month, est.day);
      if (dEst == target && (r['endTs'] == null)) {
        out.add(r);
      }
    }
    return out;
  }
}
