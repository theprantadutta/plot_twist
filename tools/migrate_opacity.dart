#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';

void main(List<String> args) async {
  print('\x1b[36m🔍 Scanning for withOpacity usage in lib folder...\x1b[0m');

  // Check for auto-yes flag
  final autoYes = args.contains('--auto-yes') || args.contains('-y');

  // Allow specifying project directory as argument
  final projectPath = Directory.current.path;
  final libDir = Directory('$projectPath/lib');

  if (!libDir.existsSync()) {
    print(
      '\x1b[31m❌ Error: lib directory not found! Make sure you\'re in your Flutter project root.\x1b[0m',
    );
    exit(1);
  }

  // First pass: scan and collect all occurrences
  final results = await scanForOccurrences(libDir);

  if (results.isEmpty) {
    print('\x1b[32m✅ No withOpacity occurrences found in lib folder.\x1b[0m');
    return;
  }

  // Show summary
  int totalFiles = results.length;
  int totalOccurrences = results.values.fold(
    0,
    (sum, list) => sum + list.length,
  );

  print('\x1b[33m\n📊 SCAN RESULTS:\x1b[0m');
  print('\x1b[37mFiles with withOpacity: \x1b[32m$totalFiles\x1b[0m');
  print('\x1b[37mTotal occurrences: \x1b[32m$totalOccurrences\x1b[0m');

  print('\x1b[33m\n📋 DETAILS:\x1b[0m');
  results.forEach((filePath, occurrences) {
    final relativePath = filePath.replaceFirst(
      Directory.current.path + Platform.pathSeparator,
      '',
    );
    print('\x1b[36m  📄 $relativePath\x1b[0m');
    for (int i = 0; i < occurrences.length; i++) {
      final occ = occurrences[i];
      print(
        '\x1b[37m    Line ${occ.lineNumber}: \x1b[33m${occ.originalText}\x1b[0m',
      );
      print('\x1b[37m              → \x1b[32m${occ.replacementText}\x1b[0m');
      if (i < occurrences.length - 1) print('');
    }
    print('');
  });

  // Ask for confirmation (unless auto-yes flag is used)
  if (!autoYes) {
    stdout.write(
      '\x1b[35m❓ Do you want to proceed with these replacements? (y/N): \x1b[0m',
    );
    final input = stdin.readLineSync()?.toLowerCase().trim() ?? '';

    if (input != 'y' && input != 'yes') {
      print('\x1b[33m⏹️  Migration cancelled.\x1b[0m');
      return;
    }
  } else {
    print(
      '\x1b[33m🤖 Auto-yes flag detected, proceeding with migrations...\x1b[0m',
    );
  }

  // Second pass: make the actual replacements
  print('\x1b[36m\n🔄 Applying changes...\x1b[0m');
  int filesModified = 0;
  int totalReplacements = 0;

  for (final entry in results.entries) {
    final filePath = entry.key;
    // final occurrences = entry.value;

    final file = File(filePath);
    final replacements = await processFile(file);

    if (replacements > 0) {
      filesModified++;
      totalReplacements += replacements;
      final relativePath = filePath.replaceFirst(
        Directory.current.path + Platform.pathSeparator,
        '',
      );
      print('\x1b[32m  ✅ $relativePath: $replacements replacements\x1b[0m');
    }
  }

  print('\x1b[32m\n🎉 Migration complete!\x1b[0m');
  print('\x1b[37mFiles modified: \x1b[32m$filesModified\x1b[0m');
  print('\x1b[37mTotal replacements: \x1b[32m$totalReplacements\x1b[0m');
  print(
    '\x1b[33m\n💡 Don\'t forget to test your app and run `flutter analyze`!\x1b[0m',
  );
}

class Occurrence {
  final int lineNumber;
  final String originalText;
  final String replacementText;

  Occurrence({
    required this.lineNumber,
    required this.originalText,
    required this.replacementText,
  });
}

Future<Map<String, List<Occurrence>>> scanForOccurrences(Directory dir) async {
  final results = <String, List<Occurrence>>{};

  await for (final entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      // Skip generated files
      if (entity.path.contains('.g.dart') ||
          entity.path.contains('.freezed.dart') ||
          entity.path.contains('.gr.dart')) {
        continue;
      }

      final occurrences = await findOccurrencesInFile(entity);
      if (occurrences.isNotEmpty) {
        results[entity.path] = occurrences;
      }
    }
  }

  return results;
}

Future<List<Occurrence>> findOccurrencesInFile(File file) async {
  try {
    final content = await file.readAsString();
    final lines = content.split('\n');
    final occurrences = <Occurrence>[];

    final regex = RegExp(r'\.withOpacity\s*\(\s*([^)]+)\s*\)');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final matches = regex.allMatches(line);

      for (final match in matches) {
        final opacityValue = match.group(1)!.trim();
        final originalText = line.trim();
        final replacementText = line
            .replaceAll(match.group(0)!, '.withValues(alpha: $opacityValue)')
            .trim();

        occurrences.add(
          Occurrence(
            lineNumber: i + 1,
            originalText: originalText,
            replacementText: replacementText,
          ),
        );
      }
    }

    return occurrences;
  } catch (e) {
    print('\x1b[31m❌ Error scanning ${file.path}: $e\x1b[0m');
    return [];
  }
}

Future<int> processFile(File file) async {
  try {
    String content = await file.readAsString();

    final regex = RegExp(r'\.withOpacity\s*\(\s*([^)]+)\s*\)');

    int replacementCount = 0;
    content = content.replaceAllMapped(regex, (match) {
      replacementCount++;
      final opacityValue = match.group(1)!.trim();
      return '.withValues(alpha: $opacityValue)';
    });

    // Only write back if changes were made
    if (replacementCount > 0) {
      await file.writeAsString(content);
    }

    return replacementCount;
  } catch (e) {
    print('\x1b[31m❌ Error processing ${file.path}: $e\x1b[0m');
    return 0;
  }
}
