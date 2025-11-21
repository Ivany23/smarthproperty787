import 'package:shared_preferences/shared_preferences.dart';

class DebugHelper {
  static Future<void> printAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    print('═══════════════════════════════════════');
    print('📋 SharedPreferences - Todos os dados:');
    print('═══════════════════════════════════════');

    for (var key in keys) {
      final value = prefs.get(key);
      print('  $key: $value (${value.runtimeType})');
    }

    print('═══════════════════════════════════════');
  }

  static Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    print('🗑️ userId removido do SharedPreferences');
  }

  static Future<void> setTestUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
    print('✅ userId de teste definido: $userId');
  }
}
