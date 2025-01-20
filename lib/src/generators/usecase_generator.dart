import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:clean_architecture_generator/clean_architecture_generator.dart';
import 'package:clean_architecture_generator/formatter/method_format.dart';
import 'package:clean_architecture_generator/formatter/names.dart';
import 'package:clean_architecture_generator/src/file_manager.dart';
import 'package:clean_architecture_generator/src/model_visitor.dart';
import 'package:source_gen/source_gen.dart';

import '../imports_file.dart';

class UseCaseGenerator extends GeneratorForAnnotation<ArchitectureAnnotation> {
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
      final basePath = FileManager.getDirectories(buildStep.inputId.path);
      final path = "$basePath/domain/use-cases";
      final methodFormat = MethodFormat();

      final repositoryType = visitor.repository;

      List<String> imports = [];
      for (var method in visitor.useCases) {
        final returnType = methodFormat.returnTypeEntity(method.type);
        final type = methodFormat.baseModelType(returnType);
        imports.add(type);
      }

      ///[UseCase]
      final classBuffer = StringBuffer();
      for (var method in visitor.useCases) {
        final useCase = StringBuffer();
        final returnType = methodFormat.returnTypeEntity(method.type);
        final type = methodFormat.responseType(returnType);
        final noParams = !method.hasRequest;
        final useCaseType = names.useCaseType(method.name);
        final requestType = noParams
            ? method.parameters.isNotEmpty
                ? "${method.parameters.first.type}"
                : 'NoParams'
            : names.requestType(method.name);
        final methodName = names.firstLower(method.name);
        useCase.writeln('///[Implementation]');

        ///[Imports]
        useCase.writeln(Imports.create(
          imports: [
            repositoryType,
            noParams ? "" : requestType,
            ...imports,
          ],
          isUseCase: noParams,
        ));
        useCase.writeln('///[$useCaseType]');
        useCase.writeln('///[Implementation]');
        useCase.writeln('@injectable');
        useCase.writeln(
            'class $useCaseType implements BaseUseCase<$requestType,Future<Either<Failure, $returnType>>>{');
        useCase.writeln('final $repositoryType repository;');
        useCase.writeln('const $useCaseType(');
        useCase.writeln('this.repository,');
        useCase.writeln(');\n');
        useCase.writeln('@override');
        useCase.writeln(
            'Future<Either<Failure, $returnType>> execute({$requestType? request,}) async {');
        useCase.writeln('return await repository.$methodName');
        if (method.parameters.length == 1) {
          useCase.writeln('(${method.parameters.first.name} : request!);');
        } else if (method.requestType == RequestType.Fields &&
            !method.hasRequest) {
          useCase.writeln(
              '(${methodFormat.requestParameters(method.parameters)});');
        } else if (method.requestType == RequestType.Body ||
            method.hasRequest) {
          useCase.writeln('(request : request!);');
        } else {
          useCase.writeln('();');
        }
        useCase.writeln('}\n}\n');

        FileManager.save(
          '$path/$useCaseType',
          useCase.toString(),
          allowUpdates: true,
        );
        classBuffer.write(useCase);
      }
    }
    return '';
  }
}
