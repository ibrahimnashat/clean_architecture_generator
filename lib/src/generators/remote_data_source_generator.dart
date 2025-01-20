import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:clean_architecture_generator/clean_architecture_generator.dart';
import 'package:clean_architecture_generator/formatter/method_format.dart';
import 'package:clean_architecture_generator/formatter/names.dart';
import 'package:clean_architecture_generator/src/imports_file.dart';
import 'package:source_gen/source_gen.dart';

import '../file_manager.dart';
import '../model_visitor.dart';

class RemoteDataSourceGenerator
    extends GeneratorForAnnotation<ArchitectureAnnotation> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final visitor = ModelVisitor();
    element.visitChildren(visitor);

    if (!visitor.isCacheOnly) {
      List<String> methods = [];
      final methodFormat = MethodFormat();
      final basePath = FileManager.getDirectories(buildStep.inputId.path);
      final path = "$basePath/data/data-sources";

      final names = Names();
      final remoteDataSource = StringBuffer();
      final clientServiceType = visitor.clientService;
      final clientServiceName = names.firstLower(clientServiceType);
      final remoteDataSourceType = visitor.remoteDataSource;
      final remoteDataSourceTypeImpl = names.ImplType(remoteDataSourceType);

      List<String> imports = [];
      for (var method in visitor.useCases) {
        final returnType = methodFormat.returnType(method.type);
        final type = methodFormat.baseModelType(returnType);
        if (method.requestType == RequestType.Body || method.hasRequest) {
          final request = names.requestType(method.name);
          imports.add(request);
        }
        imports.add(type);
      }

      ///[Imports]
      remoteDataSource.writeln(
        Imports.create(
          imports: [
            "safe_request_handler",
            "no_params",
            ...imports,
          ],
        ),
      );

      remoteDataSource.writeln('///[Implementation]');
      remoteDataSource.writeln('abstract class $remoteDataSourceType {');
      bool hasCache = false;
      for (var method in visitor.useCases) {
        final methodName = names.firstLower(method.name);
        final type = methodFormat.returnType(method.type);
        if (method.requestType == RequestType.Fields && !method.hasRequest) {
          remoteDataSource.writeln(
              'Future<Either<Failure, $type>> $methodName(${methodFormat.parameters(method.parameters)});');
        } else {
          final request = names.requestType(method.name);
          remoteDataSource.writeln(
              'Future<Either<Failure, $type>> $methodName({required $request request,});');
        }
        methods.add(methodName);
      }
      remoteDataSource.writeln('}\n');

      FileManager.save(
        '$path/$remoteDataSourceType',
        remoteDataSource.toString(),
        allowUpdates: true,
        methods: methods,
      );

      final remoteDataSourceImpl = StringBuffer();

      ///[Imports]
      remoteDataSourceImpl.writeln(Imports.create(
        imports: [
          clientServiceType,
          remoteDataSourceType,
          ...imports,
          "safe_request_handler",
          'base_response',
          "no_params",
        ],
        hasCache: hasCache,
        isRepo: true,
      ));
      remoteDataSourceImpl.writeln('///[$remoteDataSourceType]');
      remoteDataSourceImpl.writeln('///[Implementation]');
      remoteDataSourceImpl.writeln('@Injectable(as:$remoteDataSourceType)');
      remoteDataSourceImpl.writeln(
          'class $remoteDataSourceTypeImpl implements $remoteDataSourceType {');
      remoteDataSourceImpl
          .writeln('final $clientServiceType $clientServiceName;');

      remoteDataSourceImpl.writeln('final SafeApi api;');
      remoteDataSourceImpl.writeln('const $remoteDataSourceTypeImpl(');
      remoteDataSourceImpl.writeln('this.$clientServiceName,');
      remoteDataSourceImpl.writeln('this.api,');
      remoteDataSourceImpl.writeln(');\n');

      for (var method in visitor.useCases) {
        final methodName = names.firstLower(method.name);
        final type = methodFormat.returnType(method.type);
        remoteDataSourceImpl.writeln('@override');
        if (method.requestType == RequestType.Fields && !method.hasRequest) {
          remoteDataSourceImpl.writeln(
              'Future<Either<Failure, $type>> $methodName(${methodFormat.parameters(method.parameters)})async {');
          remoteDataSourceImpl.writeln('return await api<$type>(');

          remoteDataSourceImpl.writeln(
              'apiCall: $clientServiceName.${method.name}(${methodFormat.passingParameters(method.parameters)}),);');
          remoteDataSourceImpl.writeln('}\n');
        } else {
          final request = names.requestType(method.name);
          remoteDataSourceImpl.writeln(
              'Future<Either<Failure, $type>> $methodName({required $request request,})async {');
          remoteDataSourceImpl.writeln('return await api<$type>(');

          if (method.requestType == RequestType.Fields || !method.hasRequest) {
            remoteDataSourceImpl
                .writeln('apiCall: $clientServiceName.${method.name}');
            remoteDataSourceImpl.writeln(
                '(${methodFormat.requestParameters(method.parameters)}),);');
          } else {
            remoteDataSourceImpl
                .writeln('apiCall: $clientServiceName.${method.name}(');
            bool haveRequest = false;
            for (var param in method.requestParameters) {
              if (param.type == ParamType.Path ||
                  param.type == ParamType.Header ||
                  param.type == ParamType.Query) {
                remoteDataSourceImpl
                    .writeln('${param.name}:request.${param.name},');

                haveRequest = false;
              } else {
                haveRequest = true;
              }
            }
            haveRequest = haveRequest && method.requestParameters.length > 1;
            if (haveRequest) remoteDataSourceImpl.writeln('request: request,');
            remoteDataSourceImpl.writeln('),);');
          }

          remoteDataSourceImpl.writeln('}\n');
        }
      }
      remoteDataSourceImpl.writeln('}\n');

      FileManager.save(
        '$path/${remoteDataSourceType}Impl',
        remoteDataSourceImpl.toString(),
        allowUpdates: true,
        methods: methods,
      );
    }
    return "";
  }
}
