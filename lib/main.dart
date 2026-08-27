import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'core/cache/hive_cache_service.dart';
import 'core/config/supabase_config.dart';
import 'core/di/service_locator.dart';
import 'core/network/dev_http_overrides.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  configureDevHttpOverrides();

  await dotenv.load(fileName: '.env');
  await SupabaseConfig.initialize();
  await HiveCacheService.init();
  await initDependencies();

  runApp(const MyApp());
}