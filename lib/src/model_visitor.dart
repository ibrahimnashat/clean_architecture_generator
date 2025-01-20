// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:clean_architecture_generator/clean_architecture_generator.dart';
import 'package:clean_architecture_generator/formatter/method_format.dart';
import 'package:clean_architecture_generator/src/models/usecase_model.dart';

class ModelVisitor extends GeneralizingElementVisitor<void> {
  String clientService = '';
  String remoteDataSource = '';
  String localDataSource = '';
  String repository = '';
  bool isCacheOnly = false;
  List<UseCaseModel> useCases = [];
  final methodFormat = MethodFormat();

  @override
  visitConstructorElement(ConstructorElement element) {
    final returnType = element.returnType.toString();
    final className = returnType.replaceFirst('*', '');
    clientService = "${className}ClientServices";
    remoteDataSource = "${className}RemoteDataSource";
    localDataSource = "${className}LocalDataSource";
    repository = "${className}Repository";
  }

  @override
  visitMethodElement(MethodElement element) {
    final paths = element.declaration.source
        .toString()
        .replaceAll("/example/", "")
        .split('lib/');
    final path = 'lib/${paths.length == 2 ? paths[1] : paths[0]}';
    final methods = getCleanMethods(path);

    ///[cache only]
    final items =
        methods.where((item) => item.isCache && item.endPoint.isEmpty);
    isCacheOnly = items.length == methods.length;

    for (var method in methods) {
      useCases.add(
        UseCaseModel(
          cubitName: method.cubitName,
          type: "Future<${method.response}>",
          name: method.name,
          endPoint: method.endPoint,
          requestParameters: method.parameters,
          parameters: method.parameters
              .map((e) => CommendType(
                  name: e.name,
                  type: methodFormat.dataType(e.dataType),
                  isRequired: e.isRequired))
              .toList(),
          functionSets: method.parameters
              .where((e) => e.prop == ParamProp.Set)
              .map((e) => CommendType(
                  name: e.name,
                  type: methodFormat.dataType(e.dataType),
                  isRequired: e.isRequired))
              .toList(),
          textControllers: method.parameters
              .where((e) => e.prop == ParamProp.TextController)
              .map((e) => CommendType(
                  name: e.name,
                  type: methodFormat.dataType(e.dataType),
                  isRequired: e.isRequired))
              .toList(),
          emitSets: method.parameters
              .where((e) => e.prop == ParamProp.EmitSet)
              .map((e) => CommendType(
                  name: e.name,
                  type: methodFormat.dataType(e.dataType),
                  isRequired: e.isRequired))
              .toList(),
          isCache: method.isCache,
          isPaging: method.isPaging,
          requestType: method.requestType,
          methodType: method.methodType,
        ),
      );
    }
    return null;
  }
}

List<CleanMethodModel> getCleanMethods(String path) {
  final file = File(path);
  final data = file.readAsLinesSync();
  String items = removeComments(data)
      .replaceAll(";", "#")
      .replaceAll("\n", "")
      .replaceAll(RegExp('\\s+'), "")
      .trim()
      .replaceAll("methods(){return", "!");
  items = items
      .substring(items.indexOf('!') + 2, items.lastIndexOf('#') - 1)
      .replaceAll('const', "");

  final cleans = items.split("CleanMethod");
  cleans.removeWhere((item) => item.isEmpty);
  List<CleanMethodModel> methods = [];
  for (var method in cleans) {
    method = method
        .replaceAll('Param(', '{"')
        .replaceAll('MethodType.', '"')
        .replaceAll('RequestType.', '"')
        .replaceAll('ParamType.', '"')
        .replaceAll('ParamProp.', '"')
        .replaceAll('ParamDataType.', '"')
        .replaceAll('(', '{"')
        .replaceAll(')', '"}')
        .replaceAll(':', '":')
        .replaceAll(',', ',"')
        .replaceAll("'", '"')
        .replaceAll(",", '",')
        .replaceAll(',"}","', '},')
        .replaceAll('""', '"')
        .replaceAll(',]"},', ']}')
        .replaceAll('}]', '"}]')
        .replaceAll(',"}', '}')
        .replaceAll('"},', '}')
        .replaceAll('"},', '}')
        .replaceAll('"}","', '"},')
        .replaceAll('}{', '"},{')
        .replaceAll('},]', '}]')
        .replaceAll(']"},', ']}')
        .replaceAll(']"}', ']}')
        .replaceAll(',""}', '}')
        .replaceAll('""}', '"}')
        .replaceAll('true"', 'true')
        .replaceAll('false"', 'false')
        .replaceAll('},', '}')
        .replaceAll('"}{"', '"},{"')
        .replaceAll('}{', '},{');

    final data = jsonDecode(method);
    methods.add(CleanMethodModel.fromJson(data));
  }

  return methods;
}

String removeComments(List<String> lines) {
  final outputLines = <String>[];

  final commentPattern = RegExp(r'\/\/.*|\/\*[\s\S]*?\*\/');

  for (var line in lines) {
    final lineWithoutComments = line.replaceAll(commentPattern, '');
    outputLines.add(lineWithoutComments.trim());
  }

  return outputLines.join("");
}
