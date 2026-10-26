// Dosya: lib/main.dart
// Uygulamanın giriş noktası.
// Flutter motorunu hazırlar, Hive + bağımlılıkları (DI) kurar ve uygulamayı başlatır.

import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';

/// Önce yerel veritabanı ve servisler hazırlanır, sonra arayüz çizilir.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initInjection();
  runApp(const TeamTaskApp());
}
