import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:clean_architecture_generator/clean_architecture_generator.dart';
import 'package:clean_architecture_generator/src/file_manager.dart';
import 'package:clean_architecture_generator/src/imports_file.dart';
// import 'package:clean_architecture_generator/src/imports_file.dart';
import 'package:clean_architecture_generator/src/model_visitor.dart';
import 'package:source_gen/source_gen.dart';

class OptimizeGenerator extends GeneratorForAnnotation<ArchitectureAnnotation> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final path = "/lib/core/base";
    final visitor = ModelVisitor();
    element.visitChildren(visitor);

    ///[kPrint]
    final kPrint = StringBuffer();
    kPrint.writeln(Imports.create(
      libs: [
        "import 'dart:convert';",
        "import 'dart:developer';",
        "import 'package:flutter/foundation.dart';",
      ],
    ));
    kPrint.writeln('///[kPrint]');
    kPrint.writeln('///[Implementation]');
    kPrint.writeln("void kPrint(dynamic data) {");
    kPrint.writeln("if (kDebugMode) {");
    kPrint.writeln("_pr(data.toString());");
    kPrint.writeln("} else if (data is Map) {");
    kPrint.writeln("_pr(jsonEncode(data));");
    kPrint.writeln("} else {");
    kPrint.writeln("_pr(data.toString());");
    kPrint.writeln("}");
    kPrint.writeln("}\n\n");
    kPrint.writeln("void _pr(String data) {");
    kPrint.writeln("if (data.length > 500) {");
    kPrint.writeln("log(data);");
    kPrint.writeln("} else {");
    kPrint.writeln("print(data);");
    kPrint.writeln("}");
    kPrint.writeln("log(StackTrace.current.toString().split('\\n')[2]);");
    kPrint.writeln("}");

    FileManager.searchAndAddFile('$path/print', kPrint.toString());

    ///[Network]
    final network = StringBuffer();
    network.writeln(Imports.create(
      libs: [
        "import 'package:injectable/injectable.dart';",
        "import 'package:internet_connection_checker/internet_connection_checker.dart';",
      ],
    ));
    network.writeln('///[Network]');
    network.writeln('///[Implementation]');
    network.writeln("abstract class NetworkInfo {");
    network.writeln("Future<bool> get isConnected;");
    network.writeln("}\n\n");
    network.writeln("@Injectable(as: NetworkInfo)");
    network.writeln("class NetworkInfoImpl implements NetworkInfo {");
    network.writeln("InternetConnectionChecker internetConnectionChecker;");
    network.writeln("NetworkInfoImpl(this.internetConnectionChecker);");
    network.writeln("@override");
    network.writeln(
        "Future<bool> get isConnected => internetConnectionChecker.hasConnection;");
    network.writeln("}");

    FileManager.searchAndAddFile('$path/network', network.toString());

    ///[BaseUseCase]
    final baseUseCase = StringBuffer();
    baseUseCase.writeln("import 'package:eitherx/eitherx.dart';");
    baseUseCase.writeln('///[BaseUseCase]');
    baseUseCase.writeln('///[Implementation]');
    baseUseCase.writeln("abstract class BaseUseCase<RES, POS> {");
    baseUseCase.writeln("RES execute({POS? request});");
    baseUseCase.writeln("}");

    FileManager.searchAndAddFile('$path/base_use_case', baseUseCase.toString());

    ///[SafeApi]
    final safeApi = StringBuffer();
    safeApi.writeln(Imports.create(
      imports: ['print', 'network'],
      libs: [
        "import 'dart:developer';\n",
        "import 'package:eitherx/eitherx.dart';\n",
        "import 'package:injectable/injectable.dart';\n",
        "import 'package:mwidgets/mwidgets.dart';\n",
      ],
    ));
    safeApi.writeln('///[SafeApi]');
    safeApi.writeln('///[Implementation]');
    safeApi.writeln("@injectable");
    safeApi.writeln("class SafeApi {");
    safeApi.writeln("final NetworkInfo networkInfo;");
    safeApi.writeln("SafeApi(this.networkInfo);");
    safeApi.writeln("Future<Either<Failure, T>> call<T>({");
    safeApi.writeln("required Future<T> apiCall,");
    safeApi.writeln("}) async {");
    safeApi.writeln("final hasConnection = await networkInfo.isConnected;");
    safeApi.writeln("if (hasConnection) {");
    safeApi.writeln("try {");
    safeApi.writeln("final response = await apiCall;");
    safeApi.writeln("return Right(response);");
    safeApi.writeln("} catch (error) {");
    safeApi.writeln('kPrint("API Error: \$error");');
    safeApi.writeln('return Left(Failure(600, error.toString()));');
    safeApi.writeln('}');
    safeApi.writeln('} else {');
    safeApi.writeln("return Left(Failure(500, 'No Internet'));");
    safeApi.writeln('}');
    safeApi.writeln('}');
    safeApi.writeln('}');

    FileManager.searchAndAddFile(
        '$path/safe_request_handler', safeApi.toString());

    ///[BaseResponse]
    final baseResponse = StringBuffer();
    baseResponse.writeln(Imports.create(
      libs: ["import 'package:json_annotation/json_annotation.dart';"],
    ));
    baseResponse.writeln("part 'base_response.g.dart';");
    baseResponse.writeln(" @JsonSerializable(genericArgumentFactories: true)");
    baseResponse.writeln("class BaseResponse<T> {");
    baseResponse.writeln("final T? data;");
    baseResponse.writeln("String message;");
    baseResponse.writeln("bool success;");
    baseResponse.writeln("BaseResponse({");
    baseResponse.writeln("this.data,");
    baseResponse.writeln("required this.message,");
    baseResponse.writeln("required this.success,");
    baseResponse.writeln("});");
    baseResponse.writeln("factory BaseResponse.fromJson(");
    baseResponse.writeln(
        "Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>");
    baseResponse.writeln("_\$BaseResponseFromJson(json, fromJsonT);");
    baseResponse.writeln("}\n\n");

    FileManager.searchAndAddFile('$path/BaseResponse', baseResponse.toString());

    return '';
  }
}
