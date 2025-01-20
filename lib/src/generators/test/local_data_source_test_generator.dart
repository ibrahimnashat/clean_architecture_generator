import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:clean_architecture_generator/formatter/method_format.dart';
import 'package:clean_architecture_generator/formatter/names.dart';
import 'package:clean_architecture_generator/src/annotations.dart';
import 'package:clean_architecture_generator/src/file_manager.dart';
import 'package:clean_architecture_generator/src/imports_file.dart';
import 'package:source_gen/source_gen.dart';

import '../../model_visitor.dart';

class LocalDataSourceTestGenerator
    extends GeneratorForAnnotation<ArchitectureTDDAnnotation> {
  final names = Names();

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final basePath = FileManager.getDirectories(buildStep.inputId.path)
        .replaceFirst('lib', 'test');
    final path = "$basePath/data/data-sources";
    final visitor = ModelVisitor();
    final methodFormat = MethodFormat();
    element.visitChildren(visitor);
    final classBuffer = StringBuffer();
    bool hasLocalDataSource = false;
    for (var method in visitor.useCases) {
      if (method.isCache) {
        hasLocalDataSource = true;
        break;
      }
    }
    if (hasLocalDataSource) {
      List<String> imports = [];
      bool hasCache = false;

      ///[HasCache]
      for (var method in visitor.useCases) {
        final returnType = methodFormat.returnType(method.type);
        final type = methodFormat.baseModelType(returnType);
        imports.add(type);
        if (method.isCache) {
          hasCache = true;
          break;
        }
      }

      final localDataSourceType = visitor.localDataSource;
      final localDataSourceName =
          names.localDataSourceName(localDataSourceType);
      final fileName =
          "${names.camelCaseToUnderscore(localDataSourceType)}_test";

      ///[Imports]
      classBuffer.writeln(Imports.create(
        isTest: true,
        imports: [
          localDataSourceType,
          '${localDataSourceType}Impl',
          ...imports,
        ],
        libs: [
          "import 'package:shared_preferences/shared_preferences.dart';\n",
        ],
      ));

      classBuffer.writeln("import '$fileName.mocks.dart';");
      classBuffer.writeln('@GenerateNiceMocks([');
      if (hasCache) classBuffer.writeln('MockSpec<SharedPreferences>(),');
      classBuffer.writeln('])');
      classBuffer.writeln('void main() {');
      classBuffer.writeln('late $localDataSourceType $localDataSourceName;');
      classBuffer.writeln('late SharedPreferences sharedPreferences;');

      for (var method in visitor.useCases) {
        if (method.isCache) {
          final type = methodFormat.returnType(method.type);
          final modelType = names.ModelType(type);
          final dataType = methodFormat.responseType(type);
          final dataName = "${names.firstLower(modelType)}Cache";
          if (!classBuffer.toString().contains("late $dataType $dataName;")) {
            classBuffer.writeln('late $dataType $dataName;');
          }
        }
      }

      classBuffer.writeln('setUp(() {');
      if (hasCache) {
        classBuffer.writeln('sharedPreferences = MockSharedPreferences();');
      }
      classBuffer.writeln('$localDataSourceName = ${localDataSourceType}Impl(');
      if (hasCache) classBuffer.writeln('sharedPreferences,');
      classBuffer.writeln(');');

      for (var method in visitor.useCases) {
        if (method.isCache) {
          final type = methodFormat.returnType(method.type);
          final modelType = names.ModelType(type);
          final varType = names.modelRuntimeType(modelType);
          final model = names.camelCaseToUnderscore(names.ModelType(type));
          final decode = "json('expected_$model')";
          final dataName = "${names.firstLower(modelType)}Cache";
          if (varType == 'int' ||
              varType == 'double' ||
              varType == 'num' ||
              varType == 'String' ||
              varType == 'Map' ||
              varType == 'bool') {
            classBuffer.writeln(
                "$dataName = ${methodFormat.initData(varType, 'name')};");
          } else if (type.contains('List')) {
            classBuffer.writeln("$dataName = List.generate(");
            classBuffer.writeln("2,");
            classBuffer.writeln("(index) =>");
            classBuffer.writeln("$modelType.fromJson($decode),");
            classBuffer.writeln(");");
          } else {
            classBuffer.writeln("$dataName = $modelType.fromJson($decode);");
          }
        }
      }
      classBuffer.writeln('});');

      for (var method in visitor.useCases) {
        if (method.isCache) {
          final methodName = method.name;
          final key = names.keyName(methodName);
          final getCacheMethodName = names.getCacheName(methodName);
          final cacheMethodName = names.cacheName(methodName);
          final type = methodFormat.returnType(method.type);
          final modelType = names.ModelType(type);
          classBuffer.writeln("const _$key = '${names.keyValue(key)}';");
          classBuffer.writeln(
              "$cacheMethodName() => sharedPreferences.setString(_$key,");
          final dataName = "${names.firstLower(modelType)}Cache";
          if (type.contains('List')) {
            classBuffer.writeln("jsonEncode($dataName.map((item)=>");
            classBuffer.writeln("item.toJson()).toList()),);\n");
          } else {
            classBuffer.writeln("jsonEncode($dataName.toJson()),);\n");
          }
          classBuffer.writeln(
              "$getCacheMethodName() => sharedPreferences.getString(_$key);\n");
        }
      }

      classBuffer.writeln("group('$localDataSourceType', () {");
      if (visitor.useCases.isNotEmpty) {
        for (var method in visitor.useCases) {
          ///[Cache Test]
          if (method.isCache) {
            final methodName = method.name;
            final getCacheMethodName = names.getCacheName(methodName);
            final cacheMethodName = names.cacheName(methodName);
            final type = methodFormat.returnType(method.type);
            final modelType = names.ModelType(type);
            final dataName = "${names.firstLower(modelType)}Cache";
            final dataType = methodFormat.responseType(type);

            ///[Cache]
            classBuffer.writeln("///[$cacheMethodName Test]");
            classBuffer.writeln("test('$cacheMethodName', () async {");
            classBuffer.writeln(
                "when($cacheMethodName()).thenAnswer((realInvocation) async => true);");
            classBuffer.writeln(
                "final res = await $localDataSourceName.$cacheMethodName(data:$dataName);");
            classBuffer.writeln("expect(res.rightOrNull(), unit);");
            classBuffer.writeln("verify($cacheMethodName());");
            classBuffer.writeln("verifyNoMoreInteractions(sharedPreferences);");
            classBuffer.writeln("});\n");

            ///[Get Cache]
            classBuffer.writeln("///[$getCacheMethodName Test]");
            classBuffer.writeln("test('$getCacheMethodName', () async {");
            classBuffer.writeln(
                "when($getCacheMethodName()).thenAnswer((realInvocation) => ");
            if (type.contains('List')) {
              classBuffer.writeln("jsonEncode($dataName.map((item)=>");
              classBuffer.writeln("item.toJson()).toList()),);\n");
            } else {
              classBuffer.writeln("jsonEncode($dataName.toJson()),);\n");
            }
            classBuffer.writeln(
                "final res = $localDataSourceName.$getCacheMethodName();");
            classBuffer.writeln("expect(res.rightOrNull(),isA<$dataType>());");
            classBuffer.writeln("verify($getCacheMethodName());");
            classBuffer.writeln("verifyNoMoreInteractions(sharedPreferences);");
            classBuffer.writeln("});\n");
          }
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
        '$path/${localDataSourceType}Test',
        classBuffer.toString(),
        allowUpdates: true,
      );
      return classBuffer.toString();
    }
    return '';
  }
}
