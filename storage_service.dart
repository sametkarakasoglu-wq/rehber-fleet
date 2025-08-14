import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _kVehicles = 'vehicles';
  static const _kCustomers = 'customers';
  static const _kRentals = 'rentals';
  static const _kReservations = 'reservations';

  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

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

  static Future<List<Map<String, dynamic>>> getVehicles() => _getList(_kVehicles);
  static Future<void> setVehicles(List<Map<String, dynamic>> data) => _setList(_kVehicles, data);

  static Future<List<Map<String, dynamic>>> getCustomers() => _getList(_kCustomers);
  static Future<void> setCustomers(List<Map<String, dynamic>> data) => _setList(_kCustomers, data);

  static Future<List<Map<String, dynamic>>> getRentals() => _getList(_kRentals);
  static Future<void> setRentals(List<Map<String, dynamic>> data) => _setList(_kRentals, data);

  static Future<List<Map<String, dynamic>>> getReservations() => _getList(_kReservations);
  static Future<void> setReservations(List<Map<String, dynamic>> data) => _setList(_kReservations, data);
}
