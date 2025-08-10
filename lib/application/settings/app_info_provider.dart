import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_info_provider.g.dart';

// This provider fetches the app's package info (like version and build number)
@Riverpod(keepAlive: true)
Future<PackageInfo> packageInfo(Ref ref) {
  return PackageInfo.fromPlatform();
}
