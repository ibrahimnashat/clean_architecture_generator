import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:clean_architecture_generator/formatter/method_format.dart';
import 'package:clean_architecture_generator/formatter/names.dart';
import 'package:clean_architecture_generator/src/annotations.dart';
import 'package:clean_architecture_generator/src/file_manager.dart';
import 'package:clean_architecture_generator/src/imports_file.dart';
import 'package:source_gen/source_gen.dart';

import '../model_visitor.dart';

class CacheCubitGenerator
    extends GeneratorForAnnotation<ArchitectureAnnotation> {
  final names = Names();

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final path =
        "${FileManager.getDirectories(buildStep.inputId.path)}/presentation/logic";
    final visitor = ModelVisitor();

    final methodFormat = MethodFormat();
    element.visitChildren(visitor);

    List<String> imports = [];
    for (var method in visitor.useCases) {
      final returnType = methodFormat.returnTypeEntity(method.type);
      final type = methodFormat.baseModelType(returnType);
      imports.add(type);
    }

    final cubits = StringBuffer();

    for (var method in visitor.useCases) {
      final varName = names.subName(method.name);
      final requestType = names.requestType(method.name);
      final type = methodFormat.returnTypeEntity(method.type);
      final responseType = methodFormat.responseType(type);

      ///[get cache]
      if (method.isCache) {
        final getCacheCubit = StringBuffer();
        final cacheCubitType = names.getCacheCubitType(method.name);
        final cacheUseCaseName =
            names.useCaseName(names.getCacheName(method.name));
        final cacheUseCaseType =
            names.useCaseType(names.getCacheName(method.name));

        ///[Imports]
        getCacheCubit.writeln(Imports.create(
          imports: [requestType, cacheUseCaseType, ...imports],
          isCubit: true,
        ));
        getCacheCubit.writeln('@injectable');
        getCacheCubit
            .writeln('class $cacheCubitType extends Cubit<FlowState> {');
        getCacheCubit.writeln('final $cacheUseCaseType _$cacheUseCaseName;');
        if (responseType.contains('List')) {
          getCacheCubit.writeln('$responseType $varName = [];');
        } else {
          getCacheCubit.writeln('$responseType? $varName;');
        }
        getCacheCubit.writeln(
            '$cacheCubitType(this._$cacheUseCaseName) : super(FlowState());');
        getCacheCubit.writeln('void execute() {');
        getCacheCubit
            .writeln('emit(state.copyWith(type: StateType.loadingPopUp));');
        getCacheCubit.writeln('final res =  _$cacheUseCaseName.execute();');
        getCacheCubit.writeln('res.right((data) {');
        getCacheCubit.writeln('$varName = data;');
        getCacheCubit.writeln('emit(ContentState());');
        getCacheCubit.writeln('});');
        getCacheCubit.writeln('res.left((failure) {');
        getCacheCubit.writeln('emit(state.copyWith(');
        getCacheCubit.writeln('type: StateType.errorPopUp,');
        getCacheCubit.writeln('message: failure.message,');
        getCacheCubit.writeln('));');
        getCacheCubit.writeln('});');
        getCacheCubit.writeln('}');
        getCacheCubit.writeln('}');

        FileManager.save(
          '$path/$cacheCubitType',
          getCacheCubit.toString(),
          allowUpdates: true,
        );
        cubits.writeln(getCacheCubit);
      }
    }
    return cubits.toString();
  }
}
