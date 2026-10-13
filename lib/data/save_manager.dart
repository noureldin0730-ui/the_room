import 'package:shared_preferences/shared_preferences.dart';

class SaveManager {
  static Future<int> getCurrentRoom() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('current_room') ?? 1;
  }

  static Future<void> setCurrentRoom(int room) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('current_room', room);
  }

  static Future<void> clearAll() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('current_room');
  }
}