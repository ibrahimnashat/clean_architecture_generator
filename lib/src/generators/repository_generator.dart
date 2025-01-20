import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:clean_architecture_generator/formatter/method_format.dart';
import 'package:clean_architecture_generator/formatter/names.dart';
import 'package:clean_architecture_generator/src/annotations.dart';
import 'package:clean_architecture_generator/src/models/clean_method.dart';
import 'package:source_gen/source_gen.dart';

import '../file_manager.dart';
import '../imports_file.dart';
import '../model_visitor.dart';

class RepositoryGenerator
    extends GeneratorForAnnotation<ArchitectureAnnotation> {
  final names = Names();

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final visitor = ModelVisitor();
    final methodFormat = MethodFormat();
    element.visitChildren(visitor);
    final path = FileManager.getDirectories(buildStep.inputId.path);
    final abstractRepoPath = "$path/domain/repository";
    final implRepoPath = "$path/data/repository";
    List<String> methods = [];

    final repository = StringBuffer();
    String remoteDataSourceName = '';
    String remoteDataSourceType = '';
    if (!visitor.isCacheOnly)
      remoteDataSourceName = names.firstLower(visitor.remoteDataSource);

    final localDataSourceType = visitor.localDataSource;
    final localDataSourceName =
        names.localDataSourceName(visitor.localDataSource);
    if (!visitor.isCacheOnly) remoteDataSourceType = visitor.remoteDataSource;
    final repositoryType = visitor.repository;
    final repositoryImplementType = names.ImplType(repositoryType);
    final repoPath = '$abstractRepoPath/$repositoryType';
    List<String> imports = [];
    for (var method in visitor.useCases) {
      final returnTypeEntity = methodFormat.returnTypeEntity(method.type);
      final returnType = methodFormat.returnType(method.type);
      final type = methodFormat.baseModelType(returnType);
      final typeEntity = methodFormat.baseModelType(returnTypeEntity);
      if (method.requestType == RequestType.Body || method.hasRequest) {
        final request = names.requestType(method.name);
        imports.add(request);
      }
      imports.add(typeEntity);
      imports.add(type);
    }

    ///[Imports]
    repository.writeln(
      Imports.create(
        imports: [
          "no_params",
          ...imports,
        ],
      ),
    );

    repository.writeln('///[Implementation]');
    repository.writeln('abstract class $repositoryType {');
    bool hasCache = false;
    for (var method in visitor.useCases) {
      final methodName = names.firstLower(method.name);
      final typeEntity = methodFormat.returnTypeEntity(method.type);
      final responseTypeEntity = methodFormat.responseType(typeEntity);
      final type = methodFormat.returnType(method.type);
      final responseType = methodFormat.responseType(type);
      if (!visitor.isCacheOnly) {
        if (method.requestType == RequestType.Fields && !method.hasRequest) {
          repository.writeln(
              'Future<Either<Failure, $typeEntity>> $methodName(${methodFormat.parameters(method.parameters)});');
        } else {
          final request = names.requestType(method.name);
          repository.writeln(
              'Future<Either<Failure, $typeEntity>> $methodName({required $request request,});');
        }
        methods.add(methodName);
      }

      ///[cache save or get]
      if (method.isCache) {
        hasCache = true;
        final getCacheMethodName = names.getCacheName(methodName);
        final cacheMethodName = names.cacheName(methodName);
        repository.writeln(
            'Future<Either<Failure, Unit>> $cacheMethodName({required $responseType data,});');
        repository.writeln(
            'Either<Failure, $responseTypeEntity> $getCacheMethodName();');

        methods.add(cacheMethodName);
        methods.add(getCacheMethodName);
      }
    }
    repository.writeln('}\n');

    FileManager.save(
      repoPath,
      repository.toString(),
      allowUpdates: true,
      methods: methods,
    );

    final repositoryImpl = StringBuffer();

    ///[Imports]
    repositoryImpl.writeln(Imports.create(
      imports: [
        repositoryType,
        repositoryType,
        visitor.isCacheOnly ? "" : remoteDataSourceType,
        localDataSourceType,
        ...imports,
        'base_response',
        "no_params",
      ],
      hasCache: hasCache,
      isRepo: true,
    ));
    repositoryImpl.writeln('///[$repositoryImplementType]');
    repositoryImpl.writeln('///[Implementation]');
    repositoryImpl.writeln('@Injectable(as:$repositoryType)');
    repositoryImpl
        .writeln('class $repositoryImplementType implements $repositoryType {');
    if (!visitor.isCacheOnly)
      repositoryImpl
          .writeln('final $remoteDataSourceType $remoteDataSourceName;');

    ///[add cache]
    if (hasCache) {
      repositoryImpl
          .writeln('final $localDataSourceType $localDataSourceName;');
    }
    repositoryImpl.writeln('const $repositoryImplementType(');
    if (!visitor.isCacheOnly)
      repositoryImpl.writeln('this.$remoteDataSourceName,');

    ///[add cache]
    if (hasCache) {
      repositoryImpl.writeln('this.$localDataSourceName,');
    }

    repositoryImpl.writeln(');\n');

    for (var method in visitor.useCases) {
      final methodName = names.firstLower(method.name);
      final typeEntity = methodFormat.returnTypeEntity(method.type);
      final responseTypeEntity = methodFormat.responseType(typeEntity);

      final type = methodFormat.returnType(method.type);
      final responseType = methodFormat.responseType(type);
      if (!visitor.isCacheOnly) {
        repositoryImpl.writeln('@override');
        if (method.requestType == RequestType.Fields && !method.hasRequest) {
          repositoryImpl.writeln(
              'Future<Either<Failure, $typeEntity>> $methodName(${methodFormat.parameters(method.parameters)})async {');
          if (method.isCache) {
            final cacheMethodName = names.cacheName(method.name);

            repositoryImpl.writeln(
                'final res = await $remoteDataSourceName.${method.name}(${methodFormat.passingParameters(method.parameters)});');
            repositoryImpl.writeln('await res.right((data) async {');
            repositoryImpl.writeln('if (data.success) {');
            repositoryImpl.writeln(
                '$localDataSourceName.$cacheMethodName(data: data.data!);');
            repositoryImpl.writeln(' }});');
            repositoryImpl.writeln('return res;');
          } else {
            repositoryImpl.writeln(
                'return await $remoteDataSourceName.${method.name}(${methodFormat.passingParameters(method.parameters)});');
          }
          repositoryImpl.writeln('}\n');
        } else {
          final request = names.requestType(method.name);
          repositoryImpl.writeln(
              'Future<Either<Failure, $typeEntity>> $methodName({required $request request,})async {');
          if (method.isCache) {
            final cacheMethodName = names.cacheName(method.name);
            repositoryImpl.writeln(
                'final res =  await $remoteDataSourceName.${method.name}(request: request,);');
            repositoryImpl.writeln('await res.right((data) async {');
            repositoryImpl.writeln('if (data.success) {');
            repositoryImpl.writeln(
                '$localDataSourceName.$cacheMethodName(data: data.data!);');
            repositoryImpl.writeln(' }});');
            repositoryImpl.writeln('return res;');
          } else {
            repositoryImpl.writeln(
                'return await $remoteDataSourceName.${method.name}(request: request,);');
          }
          repositoryImpl.writeln('}\n');
        }
      }

      ///[cache save or get implement]
      if (method.isCache) {
        final cacheMethodName = names.cacheName(method.name);
        final getCacheMethodName = names.getCacheName(method.name);

        ///[cache]
        repositoryImpl.writeln('@override');
        repositoryImpl.writeln(
            'Future<Either<Failure, Unit>> $cacheMethodName({required $responseType data,}) async {');
        repositoryImpl.writeln(
            'return await $localDataSourceName.$cacheMethodName(data: data);');
        repositoryImpl.writeln('}\n');

        ///[get]
        repositoryImpl.writeln('@override');
        repositoryImpl.writeln(
            'Either<Failure, $responseTypeEntity> $getCacheMethodName(){');
        repositoryImpl
            .writeln('return $localDataSourceName.$getCacheMethodName();');
        repositoryImpl.writeln('}\n');
      }
    }
    repositoryImpl.writeln('}\n');
    FileManager.save(
      '$implRepoPath/${repositoryType}Impl',
      repositoryImpl.toString(),
      allowUpdates: true,
      methods: methods,
    );
    repository.writeln(repositoryImpl);
    return '';
  }
}
