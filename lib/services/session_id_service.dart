import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';


class SessionIdService {
  SessionIdService._();
  static final SessionIdService instance = SessionIdService._();

  static const _prefsKey = 'marcus_session_id';

  String? _cached;

  Future<String> getOrCreate() async {
    if (_cached != null) return _cached!;

    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_prefsKey);
    if (existing != null && existing.isNotEmpty) {
      _cached = existing;
      return existing;
    }

    final generated = _generate();
    await prefs.setString(_prefsKey, generated);
    _cached = generated;
    return generated;
  }

  String _generate() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}