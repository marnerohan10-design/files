import 'package:flutter/material.dart';

import 'app/app.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageService.create();
  runApp(ShopEaseApp(storage: storage));
}
