import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:clean_architecture_generator/formatter/method_format.dart';
import 'package:clean_architecture_generator/formatter/names.dart';
import 'package:clean_architecture_generator/src/annotations.dart';
import 'package:clean_architecture_generator/src/file_manager.dart';
import 'package:clean_architecture_generator/src/imports_file.dart';
import 'package:clean_architecture_generator/src/model_visitor.dart';
import 'package:source_gen/source_gen.dart';

class EntitiesGenerator extends GeneratorForAnnotation<ArchitectureAnnotation> {
  final names = Names();
  final format = MethodFormat();

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final currentPath = FileManager.getDirectories(buildStep.inputId.path);
    final path = "$currentPath/domain/entities";

    final visitor = ModelVisitor();
    element.visitChildren(visitor);
    final dir = Directory("$currentPath/jsons");
    if (dir.existsSync()) {
      final files = dir.listSync();
      for (var file in files) {
        String filename = file.path.split('\\').last.split('/').last;
        if (filename.contains(".json")) {
          filename = modelType(filename);
          Map<String, dynamic> data =
              jsonDecode(File(file.path).readAsStringSync());
          buildModel(filename: filename, data: data, path: path);
        }
      }
    }
    return "";
  }

  String modelType(String filename) {
    filename = names.underscoreToCamelCase(names.firstUpper(
        "${filename.replaceFirst("model", "").replaceFirst(".json", "")}Entity"));

    return filename;
  }

  void buildModel({
    required String path,
    required String filename,
    required Map<String, dynamic> data,
  }) {
    final _model = FileManager.search(filename);
    if (_model == null) {
      List<String> imports = [];
      final model = StringBuffer();
      model.writeln("class $filename {");
      for (var field in data.entries) {
        if (field.value is Map) {
          imports.add(modelType(field.key));
          model.writeln(
              'final ${modelType(field.key)}? ${names.underscoreToCamelCase(field.key)};');
          buildModel(
            path: path,
            filename: modelType(field.key),
            data: field.value,
          );
        } else {
          String type = field.value.runtimeType.toString();
          String name = names.underscoreToCamelCase(field.key);
          if (field.value is List &&
              field.value.isNotEmpty &&
              field.value.first is Map) {
            imports.add(modelType(field.key));
            type = "List<${modelType(field.key)}>";
            buildModel(
              path: path,
              filename: modelType(field.key),
              data: field.value.first,
            );
          }
          model.writeln('final $type $name;');
        }
      }

      model.writeln("const $filename({");
      for (var field in data.entries) {
        model.writeln(
            'required this.${names.underscoreToCamelCase(field.key)},');
      }
      model.writeln(" });\n");

      model.writeln("}\n");

      String _model = Imports.create(
        imports: imports,
      );

      _model = "$_model\n${model.toString()}";

      FileManager.save(
        '$path/$filename',
        _model,
        allowUpdates: true,
      );
    }
  }
}
