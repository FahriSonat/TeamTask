// Dosya: lib/features/auth/data/datasources/auth_local_datasource.dart
// Kullanıcı ve oturum bilgisinin Hive'dan okunup yazılması.

import 'package:hive/hive.dart';

import '../../../../core/constants/hive_box_names.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Kullanıcı kutusu ve oturum kutusu işlemleri sözleşmesi.
abstract interface class AuthLocalDataSource {
  Future<UserModel?> getUserByEmail(String email);
  Future<UserModel?> getUserById(String id);
  Future<void> saveUser(UserModel user);
  Future<String?> getCurrentUserId();
  Future<void> setCurrentUserId(String? userId);
}

/// Hive tabanlı gerçekleme; hatalar CacheException'a çevrilir.
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box<UserModel> userBox;
  final Box sessionBox;

  AuthLocalDataSourceImpl({required this.userBox, required this.sessionBox});

  /// E-postayı büyük/küçük harf duyarsız arar.
  @override
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final normalized = email.trim().toLowerCase();
      for (final user in userBox.values) {
        if (user.email.toLowerCase() == normalized) {
          return user;
        }
      }
      return null;
    } catch (e) {
      throw CacheException('Kullanıcı bilgisi okunurken hata oluştu: $e');
    }
  }

  /// ID ile kullanıcı getirir.
  @override
  Future<UserModel?> getUserById(String id) async {
    try {
      return userBox.get(id);
    } catch (e) {
      throw CacheException('Kullanıcı bilgisi okunurken hata oluştu: $e');
    }
  }

  /// Kullanıcıyı kaydeder / günceller.
  @override
  Future<void> saveUser(UserModel user) async {
    try {
      await userBox.put(user.id, user);
    } catch (e) {
      throw CacheException('Kullanıcı kaydedilemedi: $e');
    }
  }

  /// Oturumdaki kullanıcının ID'si.
  @override
  Future<String?> getCurrentUserId() async {
    try {
      return sessionBox.get(SessionKeys.currentUserId) as String?;
    } catch (e) {
      throw CacheException('Oturum bilgisi alınamadı: $e');
    }
  }

  /// null verilirse oturum silinir (çıkış).
  @override
  Future<void> setCurrentUserId(String? userId) async {
    try {
      if (userId == null) {
        await sessionBox.delete(SessionKeys.currentUserId);
      } else {
        await sessionBox.put(SessionKeys.currentUserId, userId);
      }
    } catch (e) {
      throw CacheException('Oturum bilgisi güncellenemedi: $e');
    }
  }
}
