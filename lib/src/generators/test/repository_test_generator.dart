import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:clean_architecture_generator/clean_architecture_generator.dart';
import 'package:clean_architecture_generator/formatter/method_format.dart';
import 'package:clean_architecture_generator/formatter/names.dart';
import 'package:clean_architecture_generator/src/file_manager.dart';
import 'package:clean_architecture_generator/src/imports_file.dart';
import 'package:source_gen/source_gen.dart';

import '../../model_visitor.dart';

class RepositoryTestGenerator
    extends GeneratorForAnnotation<ArchitectureTDDAnnotation> {
  final names = Names();

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    const expectedPath = "test";
    final basePath = FileManager.getDirectories(buildStep.inputId.path)
        .replaceFirst('lib', 'test');
    final path = "$basePath/data/repository";
    final visitor = ModelVisitor();
    final methodFormat = MethodFormat();
    element.visitChildren(visitor);
    final repository = StringBuffer();

    List<String> imports = [];
    for (var method in visitor.useCases) {
      final returnType = methodFormat.returnType(method.type);
      final type = methodFormat.baseModelType(returnType);
      if ((method.requestType == RequestType.Body && method.hasRequest) ||
          method.hasRequest) {
        final request = names.requestType(method.name);
        imports.add(request);
      }
      imports.add(type);
    }

    bool hasCache = false;

    ///[HasCache]
    for (var method in visitor.useCases) {
      if (method.isCache) {
        hasCache = true;
        break;
      }
    }

    String remoteDataSourceType = '';
    final localDataSourceType = visitor.localDataSource;
    final localDataSourceName = names.localDataSourceName(localDataSourceType);
    if (!visitor.isCacheOnly) remoteDataSourceType = visitor.remoteDataSource;
    final repositoryType = visitor.repository;
    final repositoryImplementType = names.ImplType(repositoryType);
    final fileName = "${names.camelCaseToUnderscore(repositoryType)}_test";

    ///[Imports]
    repository.writeln(Imports.create(
      imports: [
        localDataSourceType,
        visitor.isCacheOnly ? "" : remoteDataSourceType,
        '${repositoryType}Impl',
        repositoryType,
        'base_response',
        ...imports,
      ],
      libs: [
        "import 'package:mwidgets/mwidgets.dart';",
      ],
      isTest: true,
    ));
    repository.writeln("import '$fileName.mocks.dart';");
    repository.writeln('@GenerateNiceMocks([');
    if (!visitor.isCacheOnly)
      repository.writeln('MockSpec<$remoteDataSourceType>(),');
    if (hasCache) repository.writeln('MockSpec<$localDataSourceType>(),');
    repository.writeln('])');
    repository.writeln('void main() {');
    if (!visitor.isCacheOnly)
      repository.writeln('late $remoteDataSourceType dataSource;');
    repository.writeln('late $repositoryType repository;');
    repository.writeln('late Failure failure;');
    if (hasCache)
      repository.writeln('late $localDataSourceType $localDataSourceName;');

    for (var method in visitor.useCases) {
      final methodName = method.name;
      final type = methodFormat.returnType(method.type);
      if (!visitor.isCacheOnly) {
        if (!repository
            .toString()
            .contains('late $type ${methodName}Response;')) {
          repository.writeln('late $type ${methodName}Response;');
        }
        if (method.hasRequest) {
          final requestName = names.requestName(method.name);
          final requestType = names.requestType(method.name);
          repository.writeln('late $requestType $requestName;');
          if (!repository
              .toString()
              .contains('late $requestType $requestName;')) {
            repository.writeln('late $requestType $requestName;');
          }
        }
      }
      if (method.isCache) {
        final modelType = names.ModelType(type);
        final dataType = methodFormat.responseType(type);
        final dataName = "${names.firstLower(modelType)}s";
        if (!repository.toString().contains('late $dataType $dataName;')) {
          repository.writeln('late $dataType $dataName;');
        }
      }
    }

    repository.writeln('setUp(() {');
    repository.writeln('failure = Failure(999,"Cache failure");');
    if (hasCache) {
      repository.writeln('$localDataSourceName = Mock$localDataSourceType();');
    }
    if (!visitor.isCacheOnly)
      repository.writeln('dataSource = Mock$remoteDataSourceType();');
    repository.writeln('repository = $repositoryImplementType(');
    if (!visitor.isCacheOnly) repository.writeln('dataSource,');
    if (hasCache) repository.writeln('$localDataSourceName,');
    repository.writeln(');');

    for (var method in visitor.useCases) {
      final methodName = method.name;
      final type = methodFormat.returnType(method.type);
      final modelType = names.ModelType(type);
      final varType = names.modelRuntimeType(modelType);
      if (!visitor.isCacheOnly) {
        repository.writeln("///[${names.firstUpper(methodName)}]");
        repository.writeln('${methodName}Response = $type(');
        repository.writeln("message: 'message',");
        repository.writeln("success: true,");
        if (varType == 'int' ||
            varType == 'double' ||
            varType == 'num' ||
            varType == 'String' ||
            varType == 'Map' ||
            varType == 'bool') {
          repository
              .writeln("data: ${methodFormat.initData(varType, 'name')},);");
        } else if (type.contains('BaseResponse<dynamic>') ||
            type == 'BaseResponse') {
          repository.writeln("data: null,);");
        } else {
          final model = names.camelCaseToUnderscore(names.ModelType(type));
          FileManager.save(
            "$expectedPath/expected/expected_$model",
            '{}',
            extension: 'json',
          );
          final decode = "json('expected_$model')";
          if (type.contains('List')) {
            repository.writeln("data: List.generate(");
            repository.writeln("2,");
            repository.writeln("(index) =>");
            repository.writeln("$modelType.fromJson($decode),");
            repository.writeln("));");
          } else {
            repository.writeln("data: $modelType.fromJson($decode),);");
          }
        }
      }
      if (method.isCache) {
        final model = names.camelCaseToUnderscore(names.ModelType(type));
        final decode = "json('expected_$model')";
        final dataName = "${names.firstLower(modelType)}s";
        if (varType == 'int' ||
            varType == 'double' ||
            varType == 'num' ||
            varType == 'String' ||
            varType == 'Map' ||
            varType == 'bool') {
          repository.writeln(
              "$dataName = ${methodFormat.initData(varType, 'name')};");
        } else if (type.contains('List')) {
          repository.writeln("$dataName = List.generate(");
          repository.writeln("2,");
          repository.writeln("(index) =>");
          repository.writeln("$modelType.fromJson($decode),");
          repository.writeln(");");
        } else {
          repository.writeln("$dataName = $modelType.fromJson($decode);");
        }
      }
    }
    repository.writeln('});');

    for (var method in visitor.useCases) {
      final methodName = method.name;
      if (!visitor.isCacheOnly) {
        if (method.requestType == RequestType.Fields || !method.hasRequest) {
          repository.writeln(
              '$methodName() => dataSource.$methodName(${methodFormat.parametersWithValues(method.parameters)});');
        } else {
          final requestName = names.requestName(method.name);
          final requestType = names.requestType(method.name);
          repository.writeln(
              '$requestName = $requestType(${methodFormat.parametersWithValues(method.parameters)});');
          repository.writeln(
              '$methodName() => dataSource.$methodName(request: $requestName);');
        }
      }

      if (method.isCache) {
        final getCacheMethodName = names.getCacheName(methodName);
        final cacheMethodName = names.cacheName(methodName);
        final type = methodFormat.returnType(method.type);
        final modelType = names.ModelType(type);
        final dataName = "${names.firstLower(modelType)}s";
        repository.writeln(
            "$cacheMethodName() => $localDataSourceName.$cacheMethodName(data : $dataName);\n");

        repository.writeln(
            "$getCacheMethodName() => $localDataSourceName.$getCacheMethodName();\n");
      }
    }

    repository.writeln("group('$repositoryType Repository', () {");
    if (visitor.useCases.isNotEmpty) {
      for (var method in visitor.useCases) {
        final methodName = method.name;
        if (!visitor.isCacheOnly) {
          ///[Function Success Test]
          repository.writeln("///[$methodName Success Test]");
          repository.writeln("test('$methodName Success', () async {");
          repository.writeln("when($methodName())");
          repository.writeln(
              ".thenAnswer((realInvocation) async => Right(${methodName}Response));");

          if (method.requestType == RequestType.Fields || !method.hasRequest) {
            final request =
                methodFormat.parametersWithValues(method.parameters);
            repository
                .writeln("final res = await repository.$methodName($request);");
          } else {
            final requestName = names.requestName(method.name);
            repository.writeln(
                "final res = await repository.$methodName(request: $requestName);");
          }

          repository
              .writeln("expect(res.rightOrNull(), ${methodName}Response);");
          repository.writeln("verify($methodName());");
          repository.writeln("verifyNoMoreInteractions(dataSource);");
          repository.writeln("});\n");

          ///[Function Failure Test]
          repository.writeln("///[$methodName Failure Test]");
          repository.writeln("test('$methodName Failure', () async {");
          repository.writeln("when($methodName())");
          repository
              .writeln(".thenAnswer((realInvocation) async => Left(failure));");

          if (method.requestType == RequestType.Fields || !method.hasRequest) {
            final request =
                methodFormat.parametersWithValues(method.parameters);
            repository
                .writeln("final res = await repository.$methodName($request);");
          } else {
            final requestName = names.requestName(method.name);
            repository.writeln(
                "final res = await repository.$methodName(request: $requestName);");
          }

          repository.writeln("expect(res.leftOrNull(), isA<Failure>());");
          repository.writeln("verify($methodName());");
          repository.writeln("verifyNoMoreInteractions(dataSource);");
          repository.writeln("});\n");
        }

        ///[Cache Test]
        if (method.isCache) {
          final getCacheMethodName = names.getCacheName(methodName);
          final cacheMethodName = names.cacheName(methodName);
          final type = methodFormat.returnType(method.type);
          final modelType = names.ModelType(type);
          final dataName = "${names.firstLower(modelType)}s";
          final dataType = methodFormat.responseType(type);

          ///[Cache]
          repository.writeln("///[$cacheMethodName Success]");
          repository.writeln("test('$cacheMethodName', () async {");
          repository.writeln(
              "when($cacheMethodName()).thenAnswer((realInvocation) async => const Right(unit));");
          repository.writeln(
              "final res = await repository.$cacheMethodName(data:$dataName);");
          repository.writeln("expect(res.rightOrNull(), unit);");
          repository.writeln("verify($cacheMethodName());");
          repository.writeln("verifyNoMoreInteractions($localDataSourceName);");
          repository.writeln("});\n");

          repository.writeln("///[$cacheMethodName Failure]");
          repository.writeln("test('$cacheMethodName', () async {");
          repository.writeln(
              "when($cacheMethodName()).thenAnswer((realInvocation) async => Left(failure));");
          repository.writeln(
              "final res = await repository.$cacheMethodName(data:$dataName);");
          repository.writeln("expect(res.leftOrNull(), isA<Failure>());");
          repository.writeln("verify($cacheMethodName());");
          repository.writeln("verifyNoMoreInteractions($localDataSourceName);");
          repository.writeln("});\n");

          ///[Get Cache]
          repository.writeln("///[$getCacheMethodName Success]");
          repository.writeln("test('$getCacheMethodName', () async {");
          repository.writeln(
              "when($getCacheMethodName()).thenAnswer((realInvocation) => Right($dataName));\n");
          repository.writeln("final res = repository.$getCacheMethodName();");
          repository.writeln("expect(res.rightOrNull(),isA<$dataType>());");
          repository.writeln("verify($getCacheMethodName());");
          repository.writeln("verifyNoMoreInteractions($localDataSourceName);");
          repository.writeln("});\n");

          repository.writeln("///[$getCacheMethodName Failure]");
          repository.writeln("test('$getCacheMethodName', () async {");
          repository.writeln(
              "when($getCacheMethodName()).thenAnswer((realInvocation) => Left(failure));\n");
          repository.writeln("final res = repository.$getCacheMethodName();");
          repository.writeln("expect(res.leftOrNull(),isA<Failure>());");
          repository.writeln("verify($getCacheMethodName());");
          repository.writeln("verifyNoMoreInteractions($localDataSourceName);");
          repository.writeln("});\n");
        }
      }
    }
    repository.writeln("});");
    repository.writeln("}\n");
    repository.writeln("///[FromJson]");
    repository.writeln("Map<String, dynamic> json(String path) {");
    repository.writeln(
        " return jsonDecode(File('test/expected/\$path.json').readAsStringSync());");
    repository.writeln("}");
    FileManager.save(
      '$path/${repositoryType}Test',
      repository.toString(),
      allowUpdates: true,
    );
    return '';
  }
}
