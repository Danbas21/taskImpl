import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para almacenar y recuperar datos persistentes.
abstract class StorageService {
  /// Guarda un valor string con una clave específica.
  Future<bool> setString(String key, String value);

  /// Guarda un valor bool con una clave específica.
  Future<bool> setBool(String key, bool value);

  /// Guarda un valor int con una clave específica.
  Future<bool> setInt(String key, int value);

  /// Guarda una lista de strings con una clave específica.
  Future<bool> setStringList(String key, List<String> value);

  /// Guarda un objeto JSON con una clave específica.
  Future<bool> setJson(String key, Map<String, dynamic> json);

  /// Recupera un valor string por su clave.
  String? getString(String key);

  /// Recupera un valor bool por su clave.
  bool? getBool(String key);

  /// Recupera un valor int por su clave.
  int? getInt(String key);

  /// Recupera una lista de strings por su clave.
  List<String>? getStringList(String key);

  /// Recupera un objeto JSON por su clave.
  Map<String, dynamic>? getJson(String key);

  /// Elimina un valor por su clave.
  Future<bool> remove(String key);

  /// Elimina todos los valores almacenados.
  Future<bool> clear();

  /// Verifica si existe una clave específica.
  bool containsKey(String key);
}

@LazySingleton(as: StorageService)
class StorageServiceImpl implements StorageService {
  final SharedPreferences _prefs;

  StorageServiceImpl(this._prefs);

  @override
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  @override
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  @override
  Future<bool> setJson(String key, Map<String, dynamic> json) async {
    final String jsonString = jsonEncode(json);
    return await _prefs.setString(key, jsonString);
  }

  @override
  String? getString(String key) {
    return _prefs.getString(key);
  }

  @override
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  @override
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  @override
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  @override
  Map<String, dynamic>? getJson(String key) {
    final String? jsonString = _prefs.getString(key);
    if (jsonString == null) {
      return null;
    }
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  @override
  Future<bool> clear() async {
    return await _prefs.clear();
  }

  @override
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  @factoryMethod
  static Future<StorageServiceImpl> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageServiceImpl(prefs);
  }
}
