import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:clean_architecture_generator/clean_architecture_generator.dart';
import 'package:clean_architecture_generator/formatter/method_format.dart';
import 'package:clean_architecture_generator/formatter/names.dart';
import 'package:clean_architecture_generator/src/file_manager.dart';
import 'package:clean_architecture_generator/src/imports_file.dart';
import 'package:source_gen/source_gen.dart';

import '../../model_visitor.dart';

class RemoteDataSourceTestGenerator
    extends GeneratorForAnnotation<ArchitectureTDDAnnotation> {
  final names = Names();

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final visitor = ModelVisitor();
    element.visitChildren(visitor);

    if (!visitor.isCacheOnly) {
      const expectedPath = "test";
      final basePath = FileManager.getDirectories(buildStep.inputId.path)
          .replaceFirst('lib', 'test');
      final path = "$basePath/data/data-sources";
      final methodFormat = MethodFormat();
      final classBuffer = StringBuffer();

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

      final clientServicesType = visitor.clientService;
      final clientServicesName = names.firstLower(clientServicesType);
      final remoteDataSourceType = visitor.remoteDataSource;
      final remoteDataSourceImplType = names.ImplType(remoteDataSourceType);
      final fileName =
          "${names.camelCaseToUnderscore(remoteDataSourceType)}_test";

      ///[Imports]
      classBuffer.writeln(Imports.create(
        imports: [
          clientServicesType,
          remoteDataSourceType,
          '${remoteDataSourceType}Impl',
          remoteDataSourceType,
          "safe_request_handler",
          'base_response',
          'Network',
          ...imports,
        ],
        isTest: true,
      ));
      classBuffer.writeln("import '$fileName.mocks.dart';");
      classBuffer.writeln('@GenerateNiceMocks([');
      classBuffer.writeln('MockSpec<$clientServicesType>(),');
      classBuffer.writeln('MockSpec<NetworkInfo>(),');
      classBuffer.writeln('])');
      classBuffer.writeln('void main() {');
      classBuffer.writeln('late $clientServicesType dataSource;');
      classBuffer.writeln('late $remoteDataSourceType remoteDataSource;');
      classBuffer.writeln('late Failure failure;');
      classBuffer.writeln('late SafeApi apiCall;');
      classBuffer.writeln('late NetworkInfo networkInfo;');

      for (var method in visitor.useCases) {
        final methodName = method.name;
        final type = methodFormat.returnType(method.type);
        classBuffer.writeln('late $type ${methodName}Response;');
        if (method.requestType == RequestType.Body) {
          final requestName = names.requestName(method.name);
          final requestType = names.requestType(method.name);
          classBuffer.writeln('late $requestType $requestName;');
        }
      }

      classBuffer.writeln('setUp(() {');
      classBuffer.writeln('failure = Failure(999,"Cache failure");');
      classBuffer.writeln('networkInfo = MockNetworkInfo();');
      classBuffer.writeln('apiCall = SafeApi(networkInfo);');
      classBuffer.writeln('dataSource = Mock$clientServicesType();');
      classBuffer.writeln('remoteDataSource = $remoteDataSourceImplType(');
      classBuffer.writeln('dataSource,');
      classBuffer.writeln('apiCall,');
      classBuffer.writeln(');');

      for (var method in visitor.useCases) {
        final methodName = method.name;
        final type = methodFormat.returnType(method.type);
        final modelType = names.ModelType(type);
        final varType = names.modelRuntimeType(modelType);
        classBuffer.writeln("///[${names.firstUpper(methodName)}]");
        classBuffer.writeln('${methodName}Response = $type(');
        classBuffer.writeln("message: 'message',");
        classBuffer.writeln("success: true,");
        if (varType == 'int' ||
            varType == 'double' ||
            varType == 'num' ||
            varType == 'String' ||
            varType == 'Map' ||
            varType == 'bool') {
          classBuffer
              .writeln("data: ${methodFormat.initData(varType, 'name')},);");
        } else if (type.contains('BaseResponse<dynamic>') ||
            type == 'BaseResponse') {
          classBuffer.writeln("data: null,);");
        } else {
          final model = names.camelCaseToUnderscore(names.ModelType(type));
          FileManager.save(
            "$expectedPath/expected/expected_$model",
            '{}',
            extension: 'json',
          );
          final decode = "json('expected_$model')";
          if (type.contains('List')) {
            classBuffer.writeln("data: List.generate(");
            classBuffer.writeln("2,");
            classBuffer.writeln("(index) =>");
            classBuffer.writeln("$modelType.fromJson($decode),");
            classBuffer.writeln("));");
          } else {
            classBuffer.writeln("data: $modelType.fromJson($decode),);");
          }
        }
      }
      classBuffer.writeln('});');

      for (var method in visitor.useCases) {
        final methodName = method.name;
        if (method.requestType == RequestType.Fields) {
          classBuffer.writeln(
              "$methodName() => dataSource.$methodName(${methodFormat.parametersWithValues(method.parameters)});");
        } else {
          final requestName = names.requestName(method.name);
          final requestType = names.requestType(method.name);
          classBuffer.writeln(
              '$requestName = $requestType(${methodFormat.parametersWithValues(method.parameters)});');
          classBuffer.writeln("$methodName() => dataSource.$methodName(");
          bool hasRequest = false;
          for (var param in method.requestParameters) {
            if (param.type == ParamType.Query || param.type == ParamType.Path) {
              classBuffer
                  .writeln('${param.name} : $requestName.${param.name},');
            } else {
              hasRequest = true;
            }
          }
          if (hasRequest) {
            classBuffer.writeln('request : $requestName,);');
          } else {
            classBuffer.writeln(');');
          }
        }
      }

      classBuffer
          .writeln("group('$remoteDataSourceType RemoteDataSource', () {");
      if (visitor.useCases.isNotEmpty) {
        classBuffer.writeln("///[No Internet Test]");
        classBuffer.writeln("test('No Internet', () async {");
        classBuffer.writeln(
            "when(networkInfo.isConnected).thenAnswer((realInvocation) async => false);");
        final method = visitor.useCases.first;
        if (method.requestType == RequestType.Fields || !method.hasRequest) {
          final request = methodFormat.parametersWithValues(method.parameters);
          classBuffer.writeln(
              "final res = await remoteDataSource.${method.name}($request);");
        } else {
          final requestName = names.requestName(method.name);
          classBuffer.writeln(
              "final res = await remoteDataSource.${method.name}(request: $requestName);");
        }
        classBuffer.writeln("expect(res.leftOrNull(), isA<Failure>());");
        classBuffer.writeln("verify(networkInfo.isConnected);");
        classBuffer.writeln("verifyNoMoreInteractions(networkInfo);");
        classBuffer.writeln("});\n");

        for (var method in visitor.useCases) {
          final methodName = method.name;

          ///[Function Success Test]
          classBuffer.writeln("///[$methodName Success Test]");
          classBuffer.writeln("test('$methodName Success', () async {");
          classBuffer.writeln(
              "when(networkInfo.isConnected).thenAnswer((realInvocation) async => true);");
          classBuffer.writeln("when($methodName())");
          classBuffer.writeln(
              ".thenAnswer((realInvocation) async => ${methodName}Response);");

          if (method.requestType == RequestType.Fields || !method.hasRequest) {
            final request =
                methodFormat.parametersWithValues(method.parameters);
            classBuffer.writeln(
                "final res = await remoteDataSource.$methodName($request);");
          } else {
            final requestName = names.requestName(method.name);
            classBuffer.writeln(
                "final res = await remoteDataSource.$methodName(request: $requestName);");
          }

          classBuffer
              .writeln("expect(res.rightOrNull(), ${methodName}Response);");
          classBuffer.writeln("verify(networkInfo.isConnected);");
          classBuffer.writeln("verify($methodName());");
          classBuffer.writeln("verifyNoMoreInteractions(networkInfo);");
          classBuffer.writeln("verifyNoMoreInteractions(dataSource);");
          classBuffer.writeln("});\n");

          ///[Function Failure Test]
          classBuffer.writeln("///[$methodName Failure Test]");
          classBuffer.writeln("test('$methodName Failure', () async {");
          classBuffer.writeln(
              "when(networkInfo.isConnected).thenAnswer((realInvocation) async => false);");
          classBuffer.writeln("when($methodName())");
          classBuffer.writeln(
              ".thenAnswer((realInvocation) async => ${methodName}Response);");

          if (method.requestType == RequestType.Fields || !method.hasRequest) {
            final request =
                methodFormat.parametersWithValues(method.parameters);
            classBuffer.writeln(
                "final res = await remoteDataSource.$methodName($request);");
          } else {
            final requestName = names.requestName(method.name);
            classBuffer.writeln(
                "final res = await remoteDataSource.$methodName(request: $requestName);");
          }

          classBuffer.writeln("expect(res.leftOrNull(), isA<Failure>());");
          classBuffer.writeln("verify(networkInfo.isConnected);");
          classBuffer.writeln("verify($methodName());");
          classBuffer.writeln("verifyNoMoreInteractions(networkInfo);");
          classBuffer.writeln("verifyNoMoreInteractions(dataSource);");
          classBuffer.writeln("});\n");
        }
      }
      classBuffer.writeln("});");
      classBuffer.writeln("}\n");
      classBuffer.writeln("///[FromJson]");
      classBuffer.writeln("Map<String, dynamic> json(String path) {");
      classBuffer.writeln(
          " return jsonDecode(File('test/expected/\$path.json').readAsStringSync());");
      classBuffer.writeln("}");
      FileManager.save(
        '$path/${remoteDataSourceType}Test',
        classBuffer.toString(),
        allowUpdates: true,
      );
    }
    return '';
  }
}
