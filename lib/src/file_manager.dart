import 'dart:developer';
import 'dart:io';

import 'package:clean_architecture_generator/formatter/names.dart';
import 'package:clean_architecture_generator/src/check_update.dart';
import 'package:clean_architecture_generator/src/imports_file.dart';
import 'package:clean_architecture_generator/src/utilities/functions.dart';

class FileManager {
  static Names names = Names();

  static void save(
    String fileName,
    String content, {
    String extension = 'dart',
    bool allowUpdates = false,
    List<String> methods = const [],
  }) {
    _saveOrUpdate(
      fileName,
      content,
      allowUpdates: allowUpdates,
      extension: extension,
      methods: methods,
    );
  }

  static void move(String fileName, String path, String oldPath) {
    try {
      oldPath = '$oldPath/$fileName';
      path = '$path/$fileName';

      final dataSource_old = File(oldPath);

      final content = dataSource_old.readAsStringSync();

      createDirAndFile(
        path.replaceFirst(".dart", ""),
        content,
      );

      dataSource_old.deleteSync();
    } catch (e) {
      log(e.toString());
    }
  }

  static void createDirAndFile(
    String path,
    String content, {
    bool allowUpdates = false,
    String extension = 'dart',
  }) {
    path = createPath(path, extension: extension);
    final dir = Directory(getDirectories(path));
    if (!dir.existsSync()) {
      try {
        dir.createSync();
      } catch (e) {
        final paths = getDirectories(path).split('/');
        String exist = '';
        for (var path in paths) {
          exist += '$path/';
          final dir = Directory(exist);
          if (dir.existsSync()) continue;
          dir.createSync();
        }
      }
    }

    final file = File(path);
    if (!file.existsSync() || allowUpdates) {
      file.writeAsStringSync(content.formatDartCode());
    }
  }

  static Future<void> deleteDir(String path) async {
    final dir = await Directory(path);
    if (dir.existsSync()) {
      dir.delete();
    }
  }

  static String createPath(
    String fileName, {
    String extension = 'dart',
  }) {
    final projectDir = Directory.current;
    final name = "${names.camelCaseToUnderscore(fileName)}.$extension";
    return '${projectDir.path}/$name';
  }

  static String? search(String fileName) {
    final name = names.camelCaseToUnderscore(fileName.split('/').last);
    return Imports.importPath('$name.dart');
  }

  static String getDirectories(String fileName) {
    return (fileName.split('/')..removeLast()).join('/');
  }

  static void searchAndAddFile(String fileName, String content) {
    final path = search(fileName);
    if (path == null) {
      save(fileName, content);
    }
  }

  static _saveOrUpdate(
    String path,
    String content, {
    bool allowUpdates = false,
    String extension = 'dart',
    List<String> methods = const [],
  }) {
    String? import = search(path);
    if (import == null) {
      createDirAndFile(
        path,
        content.formatDartCode(),
        allowUpdates: allowUpdates,
        extension: extension,
      );
    } else {
      final file = File(import);
      if (allowUpdates) {
        content = CheckUpdate.fileContent(
          content: content,
          path: import,
          methods: methods,
        );
        file.writeAsStringSync(content.formatDartCode());
      }
    }
  }
}
