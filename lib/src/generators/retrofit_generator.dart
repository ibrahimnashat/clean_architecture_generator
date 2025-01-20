import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:clean_architecture_generator/clean_architecture_generator.dart';
import 'package:clean_architecture_generator/formatter/method_format.dart';
import 'package:clean_architecture_generator/formatter/names.dart';
import 'package:clean_architecture_generator/src/imports_file.dart';
import 'package:source_gen/source_gen.dart';

import '../file_manager.dart';
import '../model_visitor.dart';

class RetrofitGenerator extends GeneratorForAnnotation<ArchitectureAnnotation> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final visitor = ModelVisitor();
    element.visitChildren(visitor);

    if (!visitor.isCacheOnly) {
      final path =
          "${FileManager.getDirectories(buildStep.inputId.path)}/data/client-services";
      final names = Names();
      final methodFormat = MethodFormat();
      final fileName = visitor.clientService;
      final clientServices = StringBuffer();
      List<String> methods = [];

      List<String> imports = [];
      for (var method in visitor.useCases) {
        final returnType = methodFormat.returnType(method.type);
        final type = methodFormat.baseModelType(returnType);
        if (method.requestType == RequestType.Body) {
          final request = names.requestType(method.name);
          imports.add(request);
        }
        imports.add(type);
      }

      ///[Imports]
      clientServices.writeln(
        Imports.create(
          libs: [
            "import 'package:dio/dio.dart';\n",
            "import 'dart:io';\n",
            "import 'package:retrofit/retrofit.dart';\n",
            "part '${names.camelCaseToUnderscore(fileName)}.g.dart';\n"
          ],
          imports: imports..add("base_response"),
        ),
      );

      clientServices.writeln(" @RestApi()");
      clientServices.writeln(" abstract class $fileName {");
      clientServices.writeln(" factory $fileName(Dio dio, {String baseUrl}) =");
      clientServices.writeln(" _$fileName;");

      for (var method in visitor.useCases) {
        methods.add(method.name);
        if (method.methodType == MethodType.POST_MULTI_PART) {
          clientServices.writeln("     @MultiPart()");
          clientServices.writeln("     @POST('${method.endPoint}')");
        } else if (method.methodType == MethodType.PUT_MULTI_PART) {
          clientServices.writeln("     @MultiPart()");
          clientServices.writeln("     @PUT('${method.endPoint}')");
        } else {
          clientServices
              .writeln("     @${method.methodType.name}('${method.endPoint}')");
        }
        if (method.requestParameters.isNotEmpty) {
          clientServices.writeln("     ${method.type} ${method.name}({");
          if (method.requestType == RequestType.Fields) {
            if (method.methodType == MethodType.POST_MULTI_PART ||
                method.methodType == MethodType.PUT_MULTI_PART) {
              for (var param in method.requestParameters) {
                final isList = param.dataType == ParamDataType.listInt ||
                    param.dataType == ParamDataType.listString ||
                    param.dataType == ParamDataType.listFile ||
                    param.dataType == ParamDataType.listDouble;
                clientServices.writeln(
                    "         @Part(name: '${isList ? '${param.key}[]' : '${param.key}'}') ${param.isRequired ? "required" : ""} ${methodFormat.dataType(param.dataType)} ${param.isRequired ? "" : "?"} ${param.name},");
              }
            } else {
              for (var param in method.requestParameters) {
                clientServices.writeln(
                    "         @${param.type.name}('${param.key}') ${param.isRequired ? "required ${param.dataType.name}" : "${param.dataType.name}?"}  ${param.name},");
              }
            }
          } else {
            final request = names.requestType(method.name);
            bool hasRequest = false;
            for (var param in method.requestParameters) {
              if (param.type == ParamType.Query ||
                  param.type == ParamType.Header ||
                  param.type == ParamType.Path) {
                clientServices.writeln(
                    "         @${param.type.name}('${param.key}') ${param.isRequired ? "required ${param.dataType.name}" : "${param.dataType.name}?"}  ${param.name},");
              } else {
                hasRequest = true;
              }
            }
            if (hasRequest) {
              clientServices
                  .writeln("         @Body() required $request request,");
            }
          }
          clientServices.writeln("     });\n");
        } else {
          clientServices.writeln("     ${method.type} ${method.name}();\n");
        }
      }

      clientServices.writeln(" }");

      FileManager.save(
        '$path/$fileName',
        clientServices.toString(),
        allowUpdates: true,
        methods: methods,
      );
    }
    return "";
  }
}
