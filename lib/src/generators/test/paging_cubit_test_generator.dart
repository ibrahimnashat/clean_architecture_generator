import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:clean_architecture_generator/clean_architecture_generator.dart';
import 'package:clean_architecture_generator/formatter/method_format.dart';
import 'package:clean_architecture_generator/formatter/names.dart';
import 'package:clean_architecture_generator/src/generators/cubit_states.dart';
import 'package:clean_architecture_generator/src/imports_file.dart';
import 'package:clean_architecture_generator/src/models/usecase_model.dart';
import 'package:source_gen/source_gen.dart';

import '../../file_manager.dart';
import '../../model_visitor.dart';

class PagingCubitTestGenerator
    extends GeneratorForAnnotation<ArchitectureTDDAnnotation> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final visitor = ModelVisitor();
    element.visitChildren(visitor);

    if (!visitor.isCacheOnly) {
      final basePath = FileManager.getDirectories(buildStep.inputId.path)
          .replaceFirst('lib', 'test');
      final path = "$basePath/presentation/logic";
      final methodFormat = MethodFormat();
      final names = Names();

      List<String> imports = [];
      for (var method in visitor.useCases) {
        if (method.isPaging) {
          final methodName = method.name;
          final hasRequest = method.hasRequest;
          final hasTextControllers = method.hasTextControllers;
          final useCaseName = names.useCaseName(methodName);
          final useCaseType = names.useCaseType(methodName);
          final cubitType = method.cubitName;
          final fileName = "${names.camelCaseToUnderscore(cubitType)}_test";
          final returnType = methodFormat.returnType(method.type);
          final modelType = names.ModelType(returnType);
          final modelRuntimeType = names.modelRuntimeType(modelType);
          List<CommendType> parameters = method.parameters;
          String request = "";
          final type = methodFormat.baseModelType(returnType);
          imports.add(type);
          parameters.removeWhere((item) {
            final index = method.emitSets
                .indexWhere((element) => element.name == item.name);
            return index != -1;
          });
          parameters.removeWhere((item) {
            final index = method.textControllers
                .indexWhere((element) => element.name == item.name);
            return index != -1;
          });
          parameters.removeWhere((item) {
            final index = method.functionSets
                .indexWhere((element) => element.name == item.name);
            return index != -1;
          });

          String requestType = '';
          if (hasRequest) {
            requestType = names.requestType(methodName);
          }
          final cubit = StringBuffer();

          cubit.writeln(
            Imports.create(
              imports: [
                cubitType,
                useCaseType,
                requestType,
                "base_response",
                ...imports,
              ],
              libs: [
                "import 'dart:io';",
                "import 'dart:convert';",
                hasTextControllers
                    ? "import 'package:flutter/material.dart';"
                    : "",
                "import 'package:bloc_test/bloc_test.dart';",
                "import 'package:eitherx/eitherx.dart';",
                "import 'package:flutter_test/flutter_test.dart';",
                "import 'package:mockito/annotations.dart';",
                "import 'package:mockito/mockito.dart';",
                "import 'package:request_builder/request_builder.dart';",
                "import 'package:mwidgets/mwidgets.dart';",
                "import '$fileName.mocks.dart';",
              ],
            ),
          );
          cubit.writeln(" @GenerateNiceMocks([");
          if (hasTextControllers) {
            cubit.writeln("   MockSpec<TextEditingController>(),");
            cubit.writeln("   MockSpec<GlobalKey<FormState>>(),");
            cubit.writeln("   MockSpec<FormState>(),");
          }
          cubit.writeln("   MockSpec<$useCaseType>(),");
          cubit.writeln(" ])");
          cubit.writeln(" void main() {");
          cubit.writeln("   late $cubitType cubit;");
          cubit.writeln("   late $useCaseType $useCaseName;");
          for (var con in method.textControllers) {
            cubit.writeln("   late TextEditingController ${con.name};");
          }
          if (hasTextControllers) {
            cubit.writeln("   late GlobalKey<FormState> key;");
            cubit.writeln("   late FormState formState;");
          }
          if (hasRequest) {
            cubit.writeln("   late $requestType request;");
          }
          cubit.writeln("   late $returnType response;");
          cubit.writeln("   late Failure failure;");
          cubit.writeln("   setUp(() async {");
          for (var con in method.textControllers) {
            cubit.writeln("     ${con.name} = MockTextEditingController();");
          }
          if (hasTextControllers) {
            cubit.writeln("     key = MockGlobalKey();");
            cubit.writeln("     formState = MockFormState();");
          }
          cubit.writeln("     $useCaseName = Mock$useCaseType();");
          if (hasRequest) {
            cubit.writeln(
                "     request = $requestType(${methodFormat.parametersWithValues(method.parameters)});");
            request = "request : request";
          }
          cubit.writeln("///[${names.firstUpper(methodName)}]");
          cubit.writeln('response = $returnType(');
          cubit.writeln("message: 'message',");
          cubit.writeln("success: true,");
          if (modelRuntimeType == 'int' ||
              modelRuntimeType == 'double' ||
              modelRuntimeType == 'num' ||
              modelRuntimeType == 'String' ||
              modelRuntimeType == 'Map' ||
              modelRuntimeType == 'bool') {
            cubit.writeln(
                "data: ${methodFormat.initData(modelRuntimeType, 'name')},);");
          } else if (returnType.contains('BaseResponse<dynamic>') ||
              returnType == 'BaseResponse') {
            cubit.writeln("data: null,);");
          } else {
            final model =
                names.camelCaseToUnderscore(names.ModelType(returnType));
            FileManager.save(
              "test/expected/expected_$model",
              '{}',
              extension: 'json',
            );
            final decode = "json('expected_$model')";
            if (returnType.contains('List')) {
              cubit.writeln("data: List.generate(");
              cubit.writeln("2,");
              cubit.writeln("(index) =>");
              cubit.writeln("$modelType.fromJson($decode),");
              cubit.writeln("));");
            } else {
              cubit.writeln("data: $modelType.fromJson($decode),);");
            }
          }
          cubit.writeln("     failure = Failure(1, '');");
          if (hasTextControllers) {
            cubit.writeln("     cubit = $cubitType(");
            cubit.writeln("     $useCaseName,");
            cubit.writeln("     key,");
            if (hasRequest) cubit.writeln("     request,");
            for (var con in method.textControllers) {
              cubit.writeln("     ${con.name},");
            }
            cubit.writeln("     );");
          } else {
            cubit.writeln("     cubit = $cubitType($useCaseName,");
            if (hasRequest) cubit.writeln("     request,");
            cubit.writeln("     );");
          }
          cubit.writeln("   });");
          cubit.writeln(" group('$cubitType CUBIT', () {");

          final items = method.parameters.where((item) {
            return !item.name.contains("limit") && !item.name.contains("pag");
          });

          for (var param in items.toList()) {
            final index0 = method.functionSets
                .indexWhere((item) => item.name == param.name);
            final index1 =
                method.emitSets.indexWhere((item) => item.name == param.name);
            if (index0 == -1 && index1 == -1) {
              method.functionSets.add(param);
            }
            method.parameters.removeWhere((item) => item.name == param.name);
          }
          cubit.writeln("     blocTest<$cubitType, $flowState>(");
          cubit.writeln("       '$methodName failure METHOD',");
          cubit.writeln("       build: () => cubit,");
          cubit.writeln("       act: (cubit) {");
          if (hasRequest) {
            cubit.writeln("         when($useCaseName.execute($request))");
          } else if (method.requestType == RequestType.Fields &&
              method.parameters.length == 1) {
            final item = method.parameters.first;
            cubit.writeln(
                "         when($useCaseName.execute(request : ${methodFormat.initData(item.type, item.name)}))");
          } else {
            cubit.writeln(
                "         when($useCaseName.execute(${methodFormat.parametersWithValues(method.parameters)}))");
          }
          cubit.writeln(
              "             .thenAnswer((realInvocation) async => Left(failure));");
          for (var fun in method.emitSets) {
            cubit.writeln(
                "         cubit.set${names.firstUpper(fun.name)}(${methodFormat.initData(fun.type, fun.name)});");
          }
          for (var fun in method.functionSets) {
            cubit.writeln(
                "         cubit.set${names.firstUpper(fun.name)}(${methodFormat.initData(fun.type, fun.name)});");
          }
          cubit.writeln(
              "         cubit.execute(${methodFormat.parametersWithValues(parameters)});");
          cubit.writeln("       },");
          cubit.writeln("       expect: () => <$flowState>[");
          if (method.emitSets.isNotEmpty) {
            cubit.writeln("         $contentState,");
          }
          cubit.writeln("         $errorFailureState,");
          cubit.writeln("       ],");
          cubit.writeln("     );");
          cubit.writeln("     blocTest<$cubitType, $flowState>(");
          cubit.writeln("       '$methodName success METHOD',");
          cubit.writeln("       build: () => cubit,");
          cubit.writeln("       act: (cubit) {");
          if (hasRequest) {
            cubit.writeln("         when($useCaseName.execute($request))");
          } else if (method.requestType == RequestType.Fields &&
              method.parameters.length == 1) {
            final item = method.parameters.first;
            cubit.writeln(
                "         when($useCaseName.execute(request : ${methodFormat.initData(item.type, item.name)}))");
          } else {
            cubit.writeln(
                "         when($useCaseName.execute(${methodFormat.parametersWithValues(method.parameters)}))");
          }
          cubit.writeln(
              "             .thenAnswer((realInvocation) async => Right(response));");
          cubit.writeln("         cubit.init();");
          cubit.writeln(
              "         ///${parameters.map((e) => e.name).toList().toString()}");

          for (var fun in method.emitSets) {
            cubit.writeln(
                "         cubit.set${names.firstUpper(fun.name)}(${methodFormat.initData(fun.type, fun.name)});");
          }
          for (var fun in method.functionSets) {
            cubit.writeln(
                "         cubit.set${names.firstUpper(fun.name)}(${methodFormat.initData(fun.type, fun.name)});");
          }
          cubit.writeln(
              "         cubit.execute(${methodFormat.parametersWithValues(parameters)});");
          cubit.writeln("       },");
          cubit.writeln("       expect: () => <$flowState>[");
          if (method.emitSets.isNotEmpty) {
            cubit.writeln("         $contentState,");
          }
          cubit.writeln("       ],");
          cubit.writeln("     );");
          cubit.writeln("   });");
          cubit.writeln(" }");

          cubit.writeln("///[FromJson]");
          cubit.writeln("Map<String, dynamic> json(String path) {");
          cubit.writeln(
              " return jsonDecode(File('test/expected/\$path.json').readAsStringSync());");
          cubit.writeln("}");
          FileManager.save(
            '$path/$fileName',
            cubit.toString(),
          );
        }
      }
    }

    return '';
  }
}
