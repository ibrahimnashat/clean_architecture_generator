import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:clean_architecture_generator/formatter/method_format.dart';
import 'package:clean_architecture_generator/formatter/names.dart';
import 'package:clean_architecture_generator/src/annotations.dart';
import 'package:clean_architecture_generator/src/generators/cubit_states.dart';
import 'package:clean_architecture_generator/src/imports_file.dart';
import 'package:source_gen/source_gen.dart';

import '../../file_manager.dart';
import '../../model_visitor.dart';

class CacheCubitTestGenerator
    extends GeneratorForAnnotation<ArchitectureTDDAnnotation> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final basePath = FileManager.getDirectories(buildStep.inputId.path)
        .replaceFirst('lib', 'test');
    final path = "$basePath/presentation/logic";
    final visitor = ModelVisitor();
    element.visitChildren(visitor);
    final methodFormat = MethodFormat();
    final names = Names();

    List<String> imports = [];
    for (var method in visitor.useCases) {
      final returnType = methodFormat.returnType(method.type);
      final type = methodFormat.baseModelType(returnType);
      imports.add(type);
    }

    for (var method in visitor.useCases) {
      if (method.isCache) {
        final methodName = names.getCacheName(method.name);
        final useCaseName = names.useCaseName(methodName);
        final useCaseType = names.useCaseType(methodName);
        final cubitType = names.cubitType(names.getCacheName(method.cubitName));
        final fileName = "${names.camelCaseToUnderscore(cubitType)}_test";
        final returnType = methodFormat.returnType(method.type);
        final responseType = methodFormat.responseType(returnType);
        final modelType = names.ModelType(returnType);
        final modelRuntimeType = names.modelRuntimeType(modelType);
        final cubit = StringBuffer();

        cubit.writeln(
          Imports.create(
            imports: [
              cubitType,
              useCaseType,
              "base_response",
              "state_renderer",
              "states",
              "failure",
              ...imports,
            ],
            libs: [
              "import 'dart:io';",
              "import 'dart:convert';",
              "import 'package:bloc_test/bloc_test.dart';",
              "import 'package:eitherx/eitherx.dart';",
              "import 'package:flutter_test/flutter_test.dart';",
              "import 'package:mockito/annotations.dart';",
              "import 'package:mockito/mockito.dart';",
              "import 'package:request_builder/request_builder.dart';",
              "import '$fileName.mocks.dart';",
            ],
          ),
        );
        cubit.writeln(" @GenerateNiceMocks([");
        cubit.writeln("   MockSpec<$useCaseType>(),");
        cubit.writeln(" ])");
        cubit.writeln(" void main() {");
        cubit.writeln("   late $cubitType cubit;");
        cubit.writeln("   late $useCaseType $useCaseName;");
        cubit.writeln("   late $responseType response;");
        cubit.writeln("   late Failure failure;");
        cubit.writeln("   setUp(() async {");
        cubit.writeln("     $useCaseName = Mock$useCaseType();");
        cubit.writeln("///[${names.firstUpper(methodName)}]");
        cubit.writeln('response = ');
        if (modelRuntimeType == 'int' ||
            modelRuntimeType == 'double' ||
            modelRuntimeType == 'num' ||
            modelRuntimeType == 'String' ||
            modelRuntimeType == 'Map' ||
            modelRuntimeType == 'bool') {
          cubit.writeln("${methodFormat.initData(modelRuntimeType, 'name')};");
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
            cubit.writeln(" List.generate(");
            cubit.writeln("2,");
            cubit.writeln("(index) =>");
            cubit.writeln("$modelType.fromJson($decode),");
            cubit.writeln(");");
          } else {
            cubit.writeln(" $modelType.fromJson($decode);");
          }
        }
        cubit.writeln("     failure = Failure(1, '');");
        cubit.writeln("     cubit = $cubitType($useCaseName);");
        cubit.writeln("   });");
        cubit.writeln(" group('$cubitType CUBIT', () {");
        cubit.writeln("     blocTest<$cubitType, $flowState>(");
        cubit.writeln("       '$methodName failure METHOD',");
        cubit.writeln("       build: () => cubit,");
        cubit.writeln("       act: (cubit) {");
        cubit.writeln("         when($useCaseName.execute())");
        cubit.writeln(
            "             .thenAnswer((realInvocation) => Left(failure));");
        cubit.writeln("         cubit.execute();");
        cubit.writeln("       },");
        cubit.writeln("       expect: () => <$flowState>[");
        cubit.writeln("         $loadingState,");
        cubit.writeln("         $errorFailureState,");
        cubit.writeln("       ],");
        cubit.writeln("     );");
        cubit.writeln("     blocTest<$cubitType, $flowState>(");
        cubit.writeln("       '$methodName success METHOD',");
        cubit.writeln("       build: () => cubit,");
        cubit.writeln("       act: (cubit) {");
        cubit.writeln("         when($useCaseName.execute())");
        cubit.writeln(
            "             .thenAnswer((realInvocation) => Right(response));");
        cubit.writeln("         cubit.execute();");
        cubit.writeln("       },");
        cubit.writeln("       expect: () => <$flowState>[");
        cubit.writeln("         $loadingState,");
        cubit.writeln("         $contentState,");
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

    return '';
  }
}
