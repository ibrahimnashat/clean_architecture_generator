import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:clean_architecture_generator/formatter/method_format.dart';
import 'package:clean_architecture_generator/formatter/names.dart';
import 'package:clean_architecture_generator/src/annotations.dart';
import 'package:source_gen/source_gen.dart';

import '../file_manager.dart';
import '../imports_file.dart';
import '../model_visitor.dart';

class LocalDataSourceGenerator
    extends GeneratorForAnnotation<ArchitectureAnnotation> {
  final names = Names();

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final path =
        "${FileManager.getDirectories(buildStep.inputId.path)}/data/data-sources";
    final visitor = ModelVisitor();
    final methodFormat = MethodFormat();
    element.visitChildren(visitor);
    List<String> methods = [];
    bool hasLocalDataSource = false;
    for (var method in visitor.useCases) {
      if (method.isCache) {
        hasLocalDataSource = true;
        break;
      }
    }
    if (hasLocalDataSource) {
      final localDataSourceType = visitor.localDataSource;
      final localDataSourceName =
          names.localDataSourceName(visitor.localDataSource);
      final localDataSourceImplType = "${localDataSourceType}Impl";
      final localDataSourceImplName = "${localDataSourceName}Impl";

      final dataSource = StringBuffer();
      final dataSourceImpl = StringBuffer();

      List<String> imports = [];
      for (var method in visitor.useCases) {
        final returnType = methodFormat.returnType(method.type);
        final type = methodFormat.baseModelType(returnType);
        imports.add(type);
      }

      ///[Imports]
      dataSource.writeln(Imports.create(
        imports: imports,
        isLocalDataSource: true,
      ));
      dataSource.writeln('///[Implementation]');
      dataSource.writeln('abstract class $localDataSourceType {');
      for (var method in visitor.useCases) {
        final type = methodFormat.returnType(method.type);
        final responseType = methodFormat.responseType(type);

        ///[cache save or get]
        if (method.isCache) {
          final cacheMethodName = names.cacheName(method.name);
          final getCacheMethodName = names.getCacheName(method.name);
          dataSource.writeln(
              'Future<Either<Failure, Unit>> $cacheMethodName({required $responseType data,});');
          dataSource
              .writeln('Either<Failure, $responseType> $getCacheMethodName();');
          methods.add(cacheMethodName);
          methods.add(getCacheMethodName);
        }
      }

      dataSource.writeln('}\n');

      FileManager.save(
        '$path/$localDataSourceType',
        dataSource.toString(),
        allowUpdates: true,
        methods: methods,
      );

      ///[Imports]
      dataSourceImpl.writeln(Imports.create(
        imports: [
          localDataSourceName,
          ...imports,
        ],
        isLocalDataSource: true,
      ));

      dataSourceImpl.writeln('///[$localDataSourceImplType]');
      dataSourceImpl.writeln('///[Implementation]');
      dataSourceImpl.writeln('@Injectable(as:$localDataSourceType)');
      dataSourceImpl.writeln(
          'class $localDataSourceImplType implements $localDataSourceType {');
      dataSourceImpl.writeln('final SharedPreferences sharedPreferences;');
      dataSourceImpl.writeln('const $localDataSourceImplType(');
      dataSourceImpl.writeln('this.sharedPreferences,');
      dataSourceImpl.writeln(');\n');
      for (var method in visitor.useCases) {
        final type = methodFormat.returnType(method.type);
        final responseDataType = methodFormat.responseType(type);
        final modelName = names.ModelType(type);

        ///[cache save or get implement]
        if (method.isCache) {
          final cacheMethodName = names.cacheName(method.name);
          final getCacheMethodName = names.getCacheName(method.name);
          final key = names.keyName(method.name);
          dataSourceImpl
              .writeln('final _$key = "${names.keyValue(method.name)}";');

          ///[cache]
          dataSourceImpl.writeln('@override');
          dataSourceImpl.writeln(
              'Future<Either<Failure, Unit>> $cacheMethodName({required $responseDataType data,}) async {');
          dataSourceImpl.writeln('try {');
          final dataType = names.modelRuntimeType(responseDataType);
          final dynamicType = dataType == 'dynamic';
          if (dynamicType) {
            if (responseDataType.contains('List')) {
              dataSourceImpl.writeln(
                  'await sharedPreferences.setString(_$key,jsonEncode(data.map((item)=> item.toJson()).toList()));');
            } else {
              dataSourceImpl.writeln(
                  'await sharedPreferences.setString(_$key, jsonEncode(data.toJson()));');
            }
          } else {
            dataSourceImpl.writeln(
                'await sharedPreferences.set${names.firstUpper(dataType)}(_$key, data);');
          }
          dataSourceImpl.writeln('return const Right(unit);');
          dataSourceImpl.writeln('} catch (e) {');
          dataSourceImpl.writeln("return Left(Failure(999, 'Cache failure'));");
          dataSourceImpl.writeln('}');
          dataSourceImpl.writeln('}\n');

          ///[get]
          dataSourceImpl.writeln('@override');
          dataSourceImpl.writeln(
              'Either<Failure, $responseDataType> $getCacheMethodName(){');
          dataSourceImpl.writeln('try {');
          if (dynamicType) {
            dataSourceImpl.writeln(
                "final res = sharedPreferences.getString(_$key) ?? ${initVaType(dataType)};");
            if (responseDataType.contains('List')) {
              dataSourceImpl.writeln("$responseDataType data = [];");
              dataSourceImpl.writeln("for (var item in jsonDecode(res)) {");
              dataSourceImpl.writeln("data.add($modelName.fromJson(item));");
              dataSourceImpl.writeln("}");
              dataSourceImpl.writeln("return Right(data);");
            } else {
              dataSourceImpl.writeln(
                  "return Right($modelName.fromJson(jsonDecode(res)));");
            }
          } else {
            dataSourceImpl.writeln(
                "final res = sharedPreferences.get${names.firstUpper(dataType)}(_$key) ?? ${initVaType(dataType)};");
            dataSourceImpl.writeln('return Right(res);');
          }
          dataSourceImpl.writeln('} catch (e) {');
          dataSourceImpl.writeln("return Left(Failure(999, 'Cache failure'));");
          dataSourceImpl.writeln('}');
          dataSourceImpl.writeln('}\n');
        }
      }

      dataSourceImpl.writeln('}\n');

      FileManager.save(
        '$path/$localDataSourceImplName',
        dataSourceImpl.toString(),
        allowUpdates: true,
        methods: methods,
      );

      dataSource.writeln(dataSourceImpl);
      return dataSource.toString();
    }
    return '';
  }

  String initVaType(String type) {
    switch (type) {
      case 'String':
        return '""';
      case 'double':
        return '"0.0"';
      case 'int':
        return '"0"';
      case 'List':
        return '"[]"';
      case 'num':
        return '"0"';
      default:
        return '"{}"';
    }
  }
}
