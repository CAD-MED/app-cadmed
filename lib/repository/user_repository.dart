

import 'package:Cad_Med/config/database_helper.dart';
import 'package:Cad_Med/models/user.model.dart';

class UserRepository {
  final HiveHelper helper;
  final String boxName = 'logins';
  UserRepository(this.helper);

  Future<int> addUser(UserModel user) async {
    final box = helper.getBox(boxName);
    return await box.add(user.toMap());
  }

  Future<void> updateUser(int id, UserModel user) async {
    final box = helper.getBox(boxName);
    await box.put(id, user.toMap());
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final box = helper.getBox(boxName);
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final box = helper.getBox(boxName);
    final user = box.get(id);
    if (user != null) {
      return Map<String, dynamic>.from(user);
    }
    return null;
  }

  Future<Map<String, dynamic>?> getFirstUserWithKey() async {
    final box = helper.getBox(boxName);
    if (box.isNotEmpty) {
      final key = box.keys.first;
      final user = box.get(key);
      if (user != null) {
        final userMap = Map<String, dynamic>.from(user);
        userMap['key'] = key;
        return userMap;
      }
    }
    return null;
  }
}
