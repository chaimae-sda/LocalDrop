import 'dart:io';

/// Generate only the native hosts. Preserve the existing app and tests.
Future<void> main() async {
  if (!File('pubspec.yaml').existsSync() || !File('lib/main.dart').existsSync()) {
    throw StateError('Run this command from the LocalDrop project folder.');
  }
  final platforms = ['android', 'ios']
      .where((name) => !Directory(name).existsSync()).toList();
  if (platforms.isEmpty) return;
  final temp = await Directory.systemTemp.createTemp('localdrop_mobile_');
  try {
    final sdkBin = File(Platform.resolvedExecutable).parent.parent.parent.parent;
    final flutter = File('${sdkBin.path}/${Platform.isWindows ? 'flutter.bat' : 'flutter'}');
    final process = await Process.start(flutter.existsSync() ? flutter.path : 'flutter',
        ['create', '--no-pub', '--org', 'com.localdrop', '--project-name',
         'localdrop', '--platforms', platforms.join(','), '${temp.path}/localdrop'],
        runInShell: Platform.isWindows, mode: ProcessStartMode.inheritStdio);
    if (await process.exitCode != 0) throw StateError('flutter create failed');
    for (final platform in platforms) {
      await copyTree(Directory('${temp.path}/localdrop/$platform'), Directory(platform));
    }
  } finally {
    await temp.delete(recursive: true);
  }
}

Future<void> copyTree(Directory source, Directory destination) async {
  await destination.create(recursive: true);
  await for (final entry in source.list()) {
    final name = entry.path.split(Platform.pathSeparator).last;
    final path = '${destination.path}/$name';
    if (entry is Directory) await copyTree(entry, Directory(path));
    if (entry is File) await entry.copy(path);
  }
}
