// Mobile/stub implementation — used on non-web targets
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void triggerWebDownload(Uint8List bytes, String fileName) {
  // No-op on mobile
}

Future<void> saveMobileFile(Uint8List bytes, String fileName) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes);
  // ignore: avoid_print
  print('Downloaded to ${file.path}');
}
