import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:clean_architecture_generator/clean_architecture_generator.dart';
import 'package:clean_architecture_generator/formatter/method_format.dart';
import 'package:clean_architecture_generator/formatter/names.dart';
import 'package:clean_architecture_generator/src/file_manager.dart';
import 'package:clean_architecture_generator/src/model_visitor.dart';
import 'package:source_gen/source_gen.dart';

import '../imports_file.dart';

class CacheUseCaseGenerator
    extends GeneratorForAnnotation<ArchitectureAnnotation> {
  final names = Names();

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final basePath = FileManager.getDirectories(buildStep.inputId.path);
    final path = "$basePath/domain/use-cases";
    final visitor = ModelVisitor();
    final methodFormat = MethodFormat();
    element.visitChildren(visitor);

    final repositoryType = visitor.repository;

    List<String> imports = [];
    for (var method in visitor.useCases) {
      final returnType = methodFormat.returnType(method.type);
      final returnTypeEntity = methodFormat.returnTypeEntity(method.type);
      final type = methodFormat.baseModelType(returnType);
      final typeEntity = methodFormat.baseModelType(returnTypeEntity);
      imports.add(typeEntity);
      imports.add(type);
    }

    ///[UseCase]
    final classBuffer = StringBuffer();
    for (var method in visitor.useCases) {
      ///[cache save or get implement useCases]
      if (method.isCache) {
        final useCase = StringBuffer();
        final noParams = method.parameters.isEmpty;
        final cacheMethodName = names.cacheName(method.name);
        final getCacheMethodName = names.getCacheName(method.name);
        final cacheUseCaseType =
            names.useCaseType(names.cacheType(method.name));
        final getCacheUseCaseType =
            names.useCaseType(names.getCacheType(method.name));
        final type = methodFormat.returnType(method.type);
        final typeEntity = methodFormat.returnTypeEntity(method.type);
        final responseType = methodFormat.responseType(type);
        final responseTypeEntity = methodFormat.responseType(typeEntity);

        ///[cache]
        final cacheUseCase = StringBuffer();

        ///[Imports]
        cacheUseCase.writeln(Imports.create(
          imports: [repositoryType, ...imports],
          isUseCase: noParams,
          hasCache: true,
        ));
        cacheUseCase.writeln('///[$cacheUseCaseType]');
        cacheUseCase.writeln('///[Implementation]');
        cacheUseCase.writeln('@injectable');
        cacheUseCase.writeln(
            'class $cacheUseCaseType implements BaseUseCase<$responseType, Future<Either<Failure, Unit>>> {');
        cacheUseCase.writeln('final $repositoryType repository;');
        cacheUseCase.writeln('const $cacheUseCaseType(');
        cacheUseCase.writeln('this.repository,');
        cacheUseCase.writeln(');\n');
        cacheUseCase.writeln('@override');
        cacheUseCase.writeln(
            'Future<Either<Failure, Unit>> execute({$responseType? request,}) async {');
        cacheUseCase.writeln('if(request != null){');
        cacheUseCase.writeln('return await repository.$cacheMethodName');
        cacheUseCase.writeln('(data: request);');
        cacheUseCase.writeln('}');
        cacheUseCase.writeln('return const Right(unit);');
        cacheUseCase.writeln('}\n');
        cacheUseCase.writeln('}\n');
        useCase.writeln(cacheUseCase);
        FileManager.save(
          '$path/$cacheUseCaseType',
          cacheUseCase.toString(),
          allowUpdates: true,
        );

        ///[get]
        final getCacheUseCase = StringBuffer();

        ///[Imports]
        getCacheUseCase.writeln(Imports.create(
          imports: [
            repositoryType,
            getCacheUseCaseType,
            ...imports,
          ],
          isUseCase: true,
        ));
        getCacheUseCase.writeln('///[$getCacheUseCaseType]');
        getCacheUseCase.writeln('///[Implementation]');
        getCacheUseCase.writeln('@injectable');
        getCacheUseCase.writeln(
            'class $getCacheUseCaseType implements BaseUseCase<Void?, Either<Failure, $responseTypeEntity>>{');
        getCacheUseCase.writeln('final $repositoryType repository;');
        getCacheUseCase.writeln('const $getCacheUseCaseType(');
        getCacheUseCase.writeln('this.repository,');
        getCacheUseCase.writeln(');\n');
        getCacheUseCase.writeln('@override');
        getCacheUseCase.writeln(
            'Either<Failure, $responseTypeEntity> execute({Void? request,}) {');
        getCacheUseCase.writeln('return repository.$getCacheMethodName();');
        getCacheUseCase.writeln('}\n');
        getCacheUseCase.writeln('}\n');
        useCase.writeln(getCacheUseCase);
        FileManager.save(
          '$path/$getCacheUseCaseType',
          getCacheUseCase.toString(),
          allowUpdates: true,
        );
        classBuffer.write(useCase);
      }
    }
    return classBuffer.toString();
  }
}
