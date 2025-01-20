import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:clean_architecture_generator/formatter/method_format.dart';
import 'package:clean_architecture_generator/formatter/names.dart';
import 'package:clean_architecture_generator/src/annotations.dart';
import 'package:clean_architecture_generator/src/file_manager.dart';
import 'package:clean_architecture_generator/src/imports_file.dart';
import 'package:source_gen/source_gen.dart';

import '../../model_visitor.dart';

class CacheUseCaseTestGenerator
    extends GeneratorForAnnotation<ArchitectureTDDAnnotation> {
  final names = Names();

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final methodFormat = MethodFormat();
    final visitor = ModelVisitor();
    element.visitChildren(visitor);
    final basePath = FileManager.getDirectories(buildStep.inputId.path)
        .replaceFirst('lib', 'test');
    final path = "$basePath/domain/use-cases";

    final classBuffer = StringBuffer();

    List<String> imports = [];
    for (var method in visitor.useCases) {
      final returnType = methodFormat.returnType(method.type);
      final type = methodFormat.baseModelType(returnType);
      imports.add(type);
    }

    for (var method in visitor.useCases) {
      final type = methodFormat.returnType(method.type);
      final modelType = names.ModelType(type);
      final varType = names.modelRuntimeType(modelType);
      final responseType = methodFormat.responseType(type);
      final methodName = names.cacheName(method.name);
      final repositoryType = visitor.repository;
      final useCaseType = names.useCaseType(methodName);
      final useCaseName = names.useCaseName(methodName);
      final fileName = "${names.camelCaseToUnderscore(useCaseType)}_test";
      final usecase = StringBuffer();
      if (method.isCache) {
        ///[Test Caching]
        ///[Imports]
        usecase.writeln(Imports.create(
          imports: [
            useCaseType,
            repositoryType,
            ...imports,
            'base_response',
          ],
          isTest: true,
        ));
        usecase.writeln("import '$fileName.mocks.dart';");
        usecase.writeln('@GenerateNiceMocks([');
        usecase.writeln('MockSpec<$repositoryType>(),');
        usecase.writeln('])');
        usecase.writeln('void main() {');
        usecase.writeln('late $useCaseType $useCaseName;');
        usecase.writeln('late $repositoryType repository;');
        usecase.writeln('late $responseType data;');
        usecase.writeln('late Failure failure;');
        usecase.writeln('setUp(() {');
        usecase.writeln('repository = Mock$repositoryType();');
        usecase.writeln('$useCaseName = $useCaseType(repository);');
        usecase.writeln("failure = Failure(1, 'message');");
        final model = names.camelCaseToUnderscore(names.ModelType(type));
        final decode = "json('expected_$model')";

        if (varType == 'int' ||
            varType == 'double' ||
            varType == 'num' ||
            varType == 'String' ||
            varType == 'Map' ||
            varType == 'bool') {
          usecase
              .writeln("success = ${methodFormat.initData(varType, 'name')};");
        } else if (responseType.contains('List')) {
          usecase.writeln("data = List.generate(");
          usecase.writeln("2,");
          usecase.writeln("(index) =>");
          usecase.writeln("$modelType.fromJson($decode),");
          usecase.writeln(");");
        } else if (type.contains('BaseResponse<dynamic>') ||
            type == 'BaseResponse') {
          usecase.writeln("data = null,);");
        } else {
          usecase.writeln("data = $modelType.fromJson($decode);");
        }

        usecase.writeln("});\n");
        usecase
            .writeln("webService() => repository.$methodName(data: data);\n");
        usecase.writeln("group('$useCaseType ', () {");
        usecase.writeln("test('$methodName FAILURE', () async {");
        usecase.writeln(
            "when(webService()).thenAnswer((realInvocation) async => Left(failure));");
        usecase
            .writeln("final res = await $useCaseName.execute(request: data);");
        usecase.writeln("expect(res.left((data) {}), failure);");
        usecase.writeln("verify(webService());");
        usecase.writeln("verifyNoMoreInteractions(repository);");
        usecase.writeln("});\n\n");
        usecase.writeln("test('$methodName SUCCESS', () async {");
        usecase.writeln(
            "when(webService()).thenAnswer((realInvocation) async => const Right(unit));");
        usecase
            .writeln("final res = await $useCaseName.execute(request: data);");
        usecase.writeln("expect(res.right((data) {}), unit);");
        usecase.writeln("verify(webService());");
        usecase.writeln("verifyNoMoreInteractions(repository);");
        usecase.writeln("});");
        usecase.writeln("});");
        usecase.writeln("}");
        usecase.writeln("///[FromJson]");
        usecase.writeln("Map<String, dynamic> json(String path) {");
        usecase.writeln(
            " return jsonDecode(File('test/expected/\$path.json').readAsStringSync());");
        usecase.writeln("}");
        FileManager.save(
          "$path/$fileName",
          usecase.toString(),
          allowUpdates: true,
        );
        classBuffer.writeln(usecase);
      }
    }
    return classBuffer.toString();
  }
}
