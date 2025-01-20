import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:clean_architecture_generator/clean_architecture_generator.dart';
import 'package:clean_architecture_generator/formatter/method_format.dart';
import 'package:clean_architecture_generator/formatter/names.dart';
import 'package:clean_architecture_generator/src/imports_file.dart';
import 'package:source_gen/source_gen.dart';

import '../file_manager.dart';
import '../model_visitor.dart';

class RequestsGenerator extends GeneratorForAnnotation<ArchitectureAnnotation> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final visitor = ModelVisitor();
    element.visitChildren(visitor);

    if (!visitor.isCacheOnly) {
      final path =
          "${FileManager.getDirectories(buildStep.inputId.path)}/domain/requests";
      final names = Names();
      final methodFormat = MethodFormat();

      final requests = StringBuffer();

      for (var method in visitor.useCases) {
        if (!method.hasRequest && method.requestType != RequestType.Body) {
          continue;
        }
        final request = StringBuffer();
        final requestType = names.requestType(method.name);
        bool hasFile = false;
        for (var pram in method.parameters) {
          if (pram.type.contains('File')) {
            hasFile = true;
            break;
          }
        }

        ///[Imports]
        request.writeln(
          Imports.create(
            libs: [
              "import 'package:json_annotation/json_annotation.dart';\n",
              "import 'package:injectable/injectable.dart';\n",
              !hasFile
                  ? "part '${names.camelCaseToUnderscore(requestType)}.g.dart';\n"
                  : "",
            ],
          ),
        );
        request.writeln('///[$requestType]');
        request.writeln('///[Implementation]');
        request.writeln('@injectable');
        if (!hasFile) {
          request.writeln('@JsonSerializable()');
        }
        request.writeln('class $requestType {');
        for (var pram in method.parameters) {
          request.writeln(
              '${pram.isRequired && !pram.type.contains('?') ? "${pram.type}" : "${pram.type}?"} ${pram.name};');
        }
        request.writeln('$requestType({');
        for (var pram in method.parameters) {
          request.writeln(
              'this.${pram.name} ${pram.isRequired ? "= ${methodFormat.initData(pram.type.toString(), pram.name)}," : ","} ');
        }
        request.writeln('});\n');
        if (!hasFile) {
          request.writeln(
              'factory $requestType.fromJson(Map<String, dynamic> json) => _\$${requestType}FromJson(json);');
          request.writeln(
              'Map<String, dynamic> toJson() => _\$${requestType}ToJson(this);');
        }
        request.writeln('}\n');

        FileManager.save(
          '$path/$requestType',
          request.toString(),
          allowUpdates: true,
        );
        requests.write(request);
      }
    }
    return '';
  }
}
