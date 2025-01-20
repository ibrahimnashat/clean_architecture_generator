import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:clean_architecture_generator/src/annotations.dart';
import 'package:clean_architecture_generator/src/file_manager.dart';
import 'package:clean_architecture_generator/src/imports_file.dart';
import 'package:clean_architecture_generator/src/model_visitor.dart';
import 'package:source_gen/source_gen.dart';

class MoveModelsGenerator
    extends GeneratorForAnnotation<ArchitectureAnnotation> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final currentPath = FileManager.getDirectories(buildStep.inputId.path);
    final path = "$currentPath/data/models";
    final visitor = ModelVisitor();
    element.visitChildren(visitor);
    final dir = Directory("$currentPath/models");
    if (dir.existsSync()) {
      final models = Imports.filesInDir("$currentPath/models");
      for (var model in models) {
        final filename = model.split('\\').last.split('/').last;
        if (filename.contains(".dart")) {
          FileManager.move(filename, path, "$currentPath/models");
        }
      }
      final files = dir.listSync();
      if (files.isEmpty) {
        FileManager.deleteDir("$currentPath/models");
      }
    }
    return "";
  }
}
