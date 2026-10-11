import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinship_mobile/app/app.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends KinshipApp {
  const MyApp({super.key});
}
