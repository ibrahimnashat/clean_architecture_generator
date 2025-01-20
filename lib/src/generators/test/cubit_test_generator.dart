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

class CubitTestGenerator
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
      List<String> lastCubits = [];
      for (var method in visitor.useCases) {
        if (!method.isPaging) {
          List<UseCaseModel> useCases = visitor.useCases
              .where((item) => item.cubitName == method.cubitName)
              .toList();
          if (lastCubits.contains(method.cubitName)) {
            continue;
          }
          final cubitType = method.cubitName;
          final fileName = "${names.camelCaseToUnderscore(cubitType)}_test";
          for (var useCase in useCases) {
            final returnType = methodFormat.returnType(useCase.type);
            final type = methodFormat.baseModelType(returnType);
            imports.add(type);
          }

          final cubit = StringBuffer();
          List<String> useCasesType = [];
          List<String> requestsType = [];
          for (var useCase in useCases) {
            useCasesType.add(names.useCaseType(useCase.name));
            requestsType.add(names.requestType(useCase.name));
          }
          cubit.writeln(
            Imports.create(
              imports: [
                cubitType,
                ...requestsType,
                ...useCasesType,
                "base_response",
                ...imports,
              ],
              libs: [
                "import 'dart:io';",
                "import 'dart:convert';",
                "import 'package:flutter/material.dart';",
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
          for (var useCase in useCases) {
            if (useCase.hasTextControllers) {
              cubit.writeln("   MockSpec<TextEditingController>(),");
              cubit.writeln("   MockSpec<GlobalKey<FormState>>(),");
              cubit.writeln("   MockSpec<FormState>(),");
              break;
            }
          }

          for (var useCase in useCasesType) {
            cubit.writeln("   MockSpec<$useCase>(),");
          }
          cubit.writeln(" ])");
          cubit.writeln(" void main() {");
          cubit.writeln("   late $cubitType cubit;");
          for (var useCase in useCasesType) {
            final useCaseName = names.firstLower(useCase);
            cubit.writeln("   late $useCase $useCaseName;");
          }

          for (var useCase in useCases) {
            for (var con in useCase.textControllers) {
              cubit.writeln("   late TextEditingController ${con.name};");
            }
            if (useCase.hasTextControllers) {
              final useCaseName = names.useCaseName(useCase.name);
              cubit.writeln("   late GlobalKey<FormState> ${useCaseName}Key;");
              cubit.writeln("   late FormState ${useCaseName}FormState;");
            }
          }

          for (var useCase in useCases) {
            if (useCase.hasRequest) {
              final requestType = names.requestType(useCase.name);
              final requestName = names.requestName(useCase.name);
              cubit.writeln("   late $requestType $requestName;");
            }
          }
          for (var useCase in useCases) {
            final returnType = methodFormat.returnType(useCase.type);
            final returnName = names.firstLower(useCase.name);
            cubit.writeln("   late $returnType ${returnName}Response;");
          }
          cubit.writeln("   late Failure failure;");
          cubit.writeln("   setUp(() async {");

          for (var useCase in useCases) {
            final useCaseName = names.useCaseName(useCase.name);
            final useCaseType = names.useCaseType(useCase.name);
            for (var con in useCase.textControllers) {
              cubit.writeln("     ${con.name} = MockTextEditingController();");
            }
            if (useCase.hasTextControllers) {
              cubit.writeln("     ${useCaseName}Key = MockGlobalKey();");
              cubit.writeln("     ${useCaseName}FormState = MockFormState();");
              ;
            }
            cubit.writeln("     $useCaseName = Mock$useCaseType();");
          }

          for (var useCase in useCases) {
            if (useCase.hasRequest) {
              final requestType = names.requestType(useCase.name);
              final requestName = names.requestName(useCase.name);
              cubit.writeln(
                  "   $requestName = $requestType(${methodFormat.parametersWithValues(useCase.parameters)});");

              cubit.writeln("///[${names.firstUpper(useCase.name)}]");
            }
          }
          for (var useCase in useCases) {
            final returnType = methodFormat.returnType(useCase.type);
            final returnName = names.firstLower(useCase.name);
            final modelType = names.ModelType(returnType);
            final modelRuntimeType = names.modelRuntimeType(modelType);
            cubit.writeln('${returnName}Response = $returnType(');
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
          }

          cubit.writeln("     failure = Failure(1, '');");
          cubit.writeln("     cubit = $cubitType(");
          for (var useCase in useCases) {
            final useCaseName = names.useCaseName(useCase.name);
            cubit.writeln("     $useCaseName,");
            if (useCase.hasTextControllers) {
              cubit.writeln("     ${useCaseName}Key,");
            }
            if (useCase.hasRequest) {
              final requestName = names.requestName(useCase.name);
              cubit.writeln("     $requestName,");
            }
            for (var con in useCase.textControllers) {
              cubit.writeln("     ${con.name},");
            }
          }
          cubit.writeln("     );");
          cubit.writeln("   });");
          cubit.writeln(" group('$cubitType CUBIT', () {");

          for (var useCase in useCases) {
            List<CommendType> parameters = useCase.parameters;
            final hasRequest = useCase.hasRequest;
            final hasTextControllers = useCase.hasTextControllers;
            final methodName = "execute${names.firstUpper(useCase.name)}";
            final useCaseName = names.useCaseName(useCase.name);
            final requestName = names.requestName(useCase.name);
            final returnName = names.firstLower(useCase.name);
            final formKeyName = "${useCaseName}Key";
            final formStateName = "${useCaseName}FormState";
            parameters.removeWhere((item) {
              final index = useCase.emitSets
                  .indexWhere((element) => element.name == item.name);
              return index != -1;
            });
            parameters.removeWhere((item) {
              final index = useCase.textControllers
                  .indexWhere((element) => element.name == item.name);
              return index != -1;
            });
            parameters.removeWhere((item) {
              final index = useCase.functionSets
                  .indexWhere((element) => element.name == item.name);
              return index != -1;
            });

            cubit.writeln("///[${useCaseName}]");
            if (hasTextControllers) {
              cubit.writeln("     blocTest<$cubitType, $flowState>(");
              cubit.writeln("       '$methodName validation error METHOD',");
              cubit.writeln("       build: () => cubit,");
              cubit.writeln("       act: (cubit) {");
              cubit.writeln(
                  "         when($formKeyName.currentState).thenAnswer((realInvocation) => $formStateName);");
              cubit.writeln(
                  "         when($formStateName.validate()).thenAnswer((realInvocation) => false);");
              cubit.writeln(
                  "         cubit.$methodName(${methodFormat.parametersWithValues(parameters)});");
              cubit.writeln("       },");
              cubit.writeln("       expect: () => <$flowState>[],");
              cubit.writeln("     );\n");
            }
            for (var fun in useCase.emitSets) {
              cubit.writeln("     blocTest<$cubitType, $flowState>(");
              cubit.writeln("       'set${names.firstUpper(fun.name)}',");
              cubit.writeln("       build: () => cubit,");
              cubit.writeln("       act: (cubit) {");
              cubit.writeln(
                  "         cubit.set${names.firstUpper(fun.name)}(${methodFormat.initData(fun.type, fun.name)});");
              cubit.writeln("       },");
              cubit.writeln("       expect: () => <$flowState>[");
              cubit.writeln("         $contentState,");
              cubit.writeln("       ],");
              cubit.writeln("     );\n");
            }

            cubit.writeln("     blocTest<$cubitType, $flowState>(");
            cubit.writeln("       '$methodName success true status METHOD',");
            cubit.writeln("       build: () => cubit,");
            cubit.writeln("       act: (cubit) {");
            if (hasTextControllers) {
              cubit.writeln(
                  "         when($formKeyName.currentState).thenAnswer((realInvocation) => $formStateName);");
              cubit.writeln(
                  "         when($formStateName.validate()).thenAnswer((realInvocation) => true);");
            }
            for (var con in useCase.textControllers) {
              cubit.writeln(
                  "         when(${con.name}.text).thenAnswer((realInvocation) => ${methodFormat.initData(con.type, con.name)});");
            }
            if (hasRequest) {
              final request = "request : $requestName";
              cubit.writeln("         when($useCaseName.execute($request))");
            } else if (useCase.parameters.length == 1) {
              final item = useCase.parameters.first;
              cubit.writeln(
                  "         when($useCaseName.execute(request : ${methodFormat.initData(item.type, item.name)}))");
            } else {
              cubit.writeln(
                  "         when($useCaseName.execute(${methodFormat.parametersWithValues(useCase.parameters)}))");
            }
            cubit.writeln(
                "             .thenAnswer((realInvocation) async => Right(${returnName}Response));");
            for (var fun in useCase.emitSets) {
              cubit.writeln(
                  "         cubit.set${names.firstUpper(fun.name)}(${methodFormat.initData(fun.type, fun.name)});");
            }
            for (var fun in useCase.functionSets) {
              cubit.writeln(
                  "         cubit.set${names.firstUpper(fun.name)}(${methodFormat.initData(fun.type, fun.name)});");
            }
            cubit.writeln(
                "         cubit.$methodName(${methodFormat.parametersWithValues(parameters)});");
            cubit.writeln("       },");
            cubit.writeln("       expect: () => <$flowState>[");
            if (useCase.emitSets.isNotEmpty) {
              cubit.writeln("         $contentState,");
            }
            cubit.writeln("         $loadingState,");
            cubit.writeln("         $successStateTest,");
            cubit.writeln("       ],");
            cubit.writeln("     );");
            cubit.writeln("     blocTest<$cubitType, $flowState>(");
            cubit.writeln("       '$methodName success false status METHOD',");
            cubit.writeln("       build: () => cubit,");
            cubit.writeln("       act: (cubit) {");
            if (hasTextControllers) {
              cubit.writeln(
                  "         when($formKeyName.currentState).thenAnswer((realInvocation) => $formStateName);");
              cubit.writeln(
                  "         when($formStateName.validate()).thenAnswer((realInvocation) => true);");
            }
            for (var con in useCase.textControllers) {
              cubit.writeln(
                  "         when(${con.name}.text).thenAnswer((realInvocation) => ${methodFormat.initData(con.type, con.name)});");
            }
            if (hasRequest) {
              final request = "request : $requestName";
              cubit.writeln("         when($useCaseName.execute($request))");
            } else if (useCase.parameters.length == 1) {
              final item = useCase.parameters.first;
              cubit.writeln(
                  "         when($useCaseName.execute(request : ${methodFormat.initData(item.type, item.name)}))");
            } else {
              cubit.writeln(
                  "         when($useCaseName.execute(${methodFormat.parametersWithValues(method.parameters)}))");
            }
            cubit.writeln(
                "                 .thenAnswer((realInvocation) async => Right(${returnName}Response..success = false));");
            for (var fun in useCase.emitSets) {
              cubit.writeln(
                  "         cubit.set${names.firstUpper(fun.name)}(${methodFormat.initData(fun.type, fun.name)});");
            }
            for (var fun in useCase.functionSets) {
              cubit.writeln(
                  "         cubit.set${names.firstUpper(fun.name)}(${methodFormat.initData(fun.type, fun.name)});");
            }
            cubit.writeln(
                "         cubit.$methodName(${methodFormat.parametersWithValues(parameters)});");
            cubit.writeln("       },");
            cubit.writeln("       expect: () => <$flowState>[");
            if (useCase.emitSets.isNotEmpty) {
              cubit.writeln("         $contentState,");
            }
            cubit.writeln("         $loadingState,");
            cubit.writeln("         $errorStateTest,");
            cubit.writeln("       ],");
            cubit.writeln("     );\n");
            cubit.writeln("   blocTest<$cubitType, $flowState>(");
            cubit.writeln("     '$methodName failure METHOD',");
            cubit.writeln("     build: () => cubit,");
            cubit.writeln("     act: (cubit) {");
            if (hasTextControllers) {
              cubit.writeln(
                  "       when($formKeyName.currentState).thenAnswer((realInvocation) => $formStateName);");
              cubit.writeln(
                  "       when($formStateName.validate()).thenAnswer((realInvocation) => true);");
            }
            for (var con in useCase.textControllers) {
              cubit.writeln(
                  "         when(${con.name}.text).thenAnswer((realInvocation) => ${methodFormat.initData(con.type, con.name)});");
            }
            if (hasRequest) {
              final request = "request : $requestName";
              cubit.writeln("         when($useCaseName.execute($request))");
            } else if (useCase.parameters.length == 1) {
              final item = useCase.parameters.first;
              cubit.writeln(
                  "         when($useCaseName.execute(request : ${methodFormat.initData(item.type, item.name)}))");
            } else {
              cubit.writeln(
                  "         when($useCaseName.execute(${methodFormat.parametersWithValues(useCase.parameters)}))");
            }
            cubit.writeln(
                "           .thenAnswer((realInvocation) async => Left(failure));");
            for (var fun in useCase.emitSets) {
              cubit.writeln(
                  "         cubit.set${names.firstUpper(fun.name)}(${methodFormat.initData(fun.type, fun.name)});");
            }
            for (var fun in useCase.functionSets) {
              cubit.writeln(
                  "         cubit.set${names.firstUpper(fun.name)}(${methodFormat.initData(fun.type, fun.name)});");
            }

            cubit.writeln(
                "       cubit.$methodName(${methodFormat.parametersWithValues(parameters)});");
            cubit.writeln("     },");
            cubit.writeln("     expect: () => <$flowState>[");
            if (method.emitSets.isNotEmpty) {
              cubit.writeln("         $contentState,");
            }
            cubit.writeln("       $loadingState,");
            cubit.writeln("       $errorFailureState,");
            cubit.writeln("     ],");
            cubit.writeln("   );");
          }
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
