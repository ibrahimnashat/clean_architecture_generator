import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:clean_architecture_generator/formatter/method_format.dart';
import 'package:clean_architecture_generator/formatter/names.dart';
import 'package:clean_architecture_generator/src/annotations.dart';
import 'package:clean_architecture_generator/src/file_manager.dart';
import 'package:clean_architecture_generator/src/imports_file.dart';
import 'package:source_gen/source_gen.dart';

import '../model_visitor.dart';

class CubitGenerator extends GeneratorForAnnotation<ArchitectureAnnotation> {
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
      final cubit = StringBuffer();
      final varName = names.subName(method.name);
      final hasParams = method.hasRequest;
      final cubitType = names.cubitType(method.name);
      final useCaseType = names.useCaseType(method.name);
      final requestType = names.requestType(method.name);
      final type = methodFormat.returnTypeEntity(method.type);
      final responseType = methodFormat.responseType(type);
      final baseModelType = methodFormat.baseModelType(type);
      final hasData = !type.contains('BaseResponse<dynamic>');
      final hasTextController = method.hasTextControllers;
      final hasFunctionSet = method.hasSets;
      final hasEmitSet = method.hasEmitSets;

      ///[Imports]
      cubit.writeln(Imports.create(
        imports: [useCaseType, hasParams ? requestType : "", ...imports],
        isCubit: true,
        isPaging: method.isPaging,
      ));

      cubit.writeln('///[$cubitType]');
      cubit.writeln('///[Implementation]');
      cubit.writeln('@injectable');
      cubit.writeln('class $cubitType extends Cubit<FlowState> {');
      cubit.writeln('final $useCaseType _${names.firstLower(useCaseType)};');
      if (hasParams) cubit.writeln('final $requestType request;');
      if (method.isPaging) {
        ///[initialize formKey for validation]
        if (hasTextController) {
          cubit.writeln('final GlobalKey<FormState> formKey;');
        }

        ///[initialize controller for TextEditingController]
        for (var controller in method.textControllers) {
          cubit.writeln('final TextEditingController ${controller.name};');
          method.parameters
              .removeWhere((element) => controller.name == element.name);
        }

        cubit.writeln(
            'late final PagewiseLoadController<$baseModelType> pagewiseController;');
        cubit.writeln('$cubitType(this._${names.firstLower(useCaseType)},');
        if (hasTextController) cubit.writeln('this.formKey,');
        for (var controller in method.textControllers) {
          cubit.writeln('this.${controller.name},');
        }
        if (hasParams) cubit.writeln('this.request,');
        cubit.writeln(') : super(FlowState());');
        cubit.writeln('void init() {');
        cubit.writeln(
            'pagewiseController = PagewiseLoadController<$baseModelType>(');
        cubit.writeln('pageSize: 10,');
        cubit.writeln('pageFuture: (page) {');
        final items = method.parameters.where((item) {
          return item.name.contains("limit") || item.name.contains("pag");
        });
        final index =
            method.parameters.indexWhere((item) => item.name.contains("pag"));
        String pageItemName = 'page';
        if (index != -1) {
          pageItemName = method.parameters[index].name;
        }
        if (items.length == 2) {
          cubit.writeln(
              'return execute($pageItemName : page!,limit : page * 10);');
        } else if (index != -1) {
          cubit.writeln('return execute($pageItemName : page!);');
        } else {
          try {
            final index = method.parameters
                .firstWhere((item) => item.type.contains("int"));
            cubit.writeln('return execute(${index.name} : page!);');
          } catch (e) {
            cubit.writeln('return execute();');
          }
        }
        cubit.writeln('},');
        cubit.writeln(');');
        cubit.writeln('}');

        final params = method.parameters.where((item) {
          return !item.name.contains("limit") && !item.name.contains("pag");
        });

        for (var param in params.toList()) {
          final index0 =
              method.functionSets.indexWhere((item) => item.name == param.name);
          final index1 =
              method.emitSets.indexWhere((item) => item.name == param.name);
          if (index0 == -1 && index1 == -1) {
            method.functionSets.add(param);
          }
          method.parameters.removeWhere((item) => item.name == param.name);
        }

        ///[initialize variable for set emit function]
        for (var function in method.emitSets) {
          cubit.write('${function.type} ${function.name}');
          cubit.write(initVaType(function.type));
          method.parameters
              .removeWhere((element) => function.name == element.name);
        }

        ///[initialize variable for set function]
        for (var function in method.functionSets) {
          cubit.write('${function.type} ${function.name}');
          cubit.write(initVaType(function.type));
          method.parameters
              .removeWhere((element) => function.name == element.name);
        }

        if (method.hasRequest) {
          cubit.writeln(
              'Future<$responseType> execute(${methodFormat.parameters(method.parameters)}) async {');
        } else if (method.parameters.isNotEmpty) {
          cubit.writeln(
              'Future<$responseType> execute({required ${method.parameters.first.type} ${method.parameters.first.name}}) async {');
        }
        cubit.writeln('$responseType $varName = [];');
        if (hasTextController) {
          cubit.writeln('if (formKey.currentState!.validate()) {');
        }

        ///[add textEditController to request]
        if (hasTextController) {
          for (var controller in method.textControllers) {
            if (method.hasRequest) {
              cubit.writeln('request.${controller.name} =');
            }
            if (controller.type == 'int') {
              cubit.writeln('int.parse(${controller.name}.text);');
            } else if (controller.type == 'double') {
              cubit.writeln('double.parse(${controller.name}.text);');
            } else if (controller.type == 'num') {
              cubit.writeln('num.parse(${controller.name}.text);');
            } else {
              cubit.writeln('${controller.name}.text;');
            }
          }
        }

        ///[add variables to request]
        for (var function in method.emitSets) {
          if (method.hasRequest) {
            cubit.writeln('request.${function.name} = ${function.name};');
          }
        }

        ///[add variables to request]
        for (var function in method.functionSets) {
          if (method.hasRequest) {
            cubit.writeln('request.${function.name} = ${function.name};');
          }
        }

        ///[add params to request]
        for (var parma in method.parameters) {
          if (method.hasRequest) {
            cubit.writeln('request.${parma.name} = ${parma.name};');
          }
        }
        cubit.writeln(
            'final res = await _${names.firstLower(useCaseType)}.execute(');
        if (hasParams) {
          cubit.writeln("request : request,");
        } else {
          cubit.writeln('request : ${method.parameters.first.name},');
        }
        cubit.writeln(');');
        cubit.writeln('res.left((failure) {');
        cubit.writeln('emit(state.copyWith(');
        cubit.writeln('type: StateType.errorPopUp,');
        cubit.writeln('message: failure.message,');
        cubit.writeln('));');
        cubit.writeln('});');
        cubit.writeln('res.right((data) {');
        if (hasData) {
          cubit.writeln('if(data.data != null){');
          cubit.writeln('$varName = data.data!;');
          cubit.writeln('}');
        }
        cubit.writeln('});');
        cubit.writeln('return $varName;');
        if (hasTextController) {
          cubit.writeln('}');
        }
        cubit.writeln('}');

        ///[create emit set]
        for (var function in method.emitSets) {
          cubit.writeln(
              'void set${names.firstUpper(function.name)}(${function.type} value){');
          cubit.writeln('${function.name} = value;');
          cubit.writeln('emit(state.copyWith(type: StateType.none));');
          cubit.writeln('}');
        }

        ///[create set function]
        for (var function in method.functionSets) {
          cubit.writeln(
              'void set${names.firstUpper(function.name)}(${function.type} value){');
          cubit.writeln('${function.name} = value;');
          cubit.writeln('}');
        }
        cubit.writeln('}');
      } else {
        ///[initialize formKey for validation]
        if (hasTextController) {
          cubit.writeln('final GlobalKey<FormState> formKey;');
        }

        ///[initialize controller for TextEditingController]
        for (var controller in method.textControllers) {
          cubit.writeln('final TextEditingController ${controller.name};');
          method.parameters
              .removeWhere((element) => controller.name == element.name);
        }

        ///[initialize constructor]
        cubit.writeln('$cubitType(this._${names.firstLower(useCaseType)},');
        if (hasTextController) cubit.writeln('this.formKey,');
        if (hasParams) cubit.writeln('this.request,');
        for (var controller in method.textControllers) {
          cubit.writeln('this.${controller.name},');
        }
        cubit.writeln(') : super(FlowState());\n');

        ///[initialize var for data when cubit is get request]
        if (hasData) {
          if (responseType.contains('List')) {
            cubit.writeln('$responseType $varName = [];');
          } else {
            cubit.writeln('$responseType? $varName;');
          }
        }

        ///[initialize variable for set emit function]
        for (var function in method.emitSets) {
          cubit.write('${function.type} ${function.name}');
          cubit.write(initVaType(function.type));
          method.parameters
              .removeWhere((element) => function.name == element.name);
        }

        ///[initialize variable for set function]
        for (var function in method.functionSets) {
          cubit.write('${function.type} ${function.name}');
          cubit.write(initVaType(function.type));
          method.parameters
              .removeWhere((element) => function.name == element.name);
        }

        cubit.writeln('\n');
        cubit.writeln(
            'Future<void> execute(${methodFormat.parameters(method.parameters)}) async {');
        if (hasTextController) {
          cubit.writeln('if (formKey.currentState!.validate()) {');
        }

        ///[add textEditController to request]
        if (hasTextController) {
          for (var controller in method.textControllers) {
            if (method.hasRequest) {
              cubit.writeln('request.${controller.name} =');
            }
            if (controller.type == 'int') {
              cubit.writeln('int.parse(${controller.name}.text);');
            } else if (controller.type == 'double') {
              cubit.writeln('double.parse(${controller.name}.text);');
            } else if (controller.type == 'num') {
              cubit.writeln('num.parse(${controller.name}.text);');
            } else {
              cubit.writeln('${controller.name}.text;');
            }
          }
        }

        ///[add variables to request]
        for (var function in method.emitSets) {
          if (method.hasRequest) {
            cubit.writeln('request.${function.name} = ${function.name};');
          }
        }

        ///[add variables to request]
        for (var function in method.functionSets) {
          if (method.hasRequest) {
            cubit.writeln('request.${function.name} = ${function.name};');
          }
        }

        ///[add params to request]
        for (var parma in method.parameters) {
          if (method.hasRequest) {
            cubit.writeln('request.${parma.name} = ${parma.name};');
          }
        }

        cubit.writeln('emit(state.copyWith(type: StateType.loadingPopUp));');
        cubit.writeln(
            'final res = await _${names.firstLower(useCaseType)}.execute(');

        ///[add request]
        if (method.hasRequest) {
          if (method.hasRequest ||
              hasTextController ||
              hasFunctionSet ||
              hasEmitSet) {
            cubit.writeln("request : request,");
          }
        } else {
          for (var controller in method.textControllers) {
            cubit.writeln('request : ${controller.name}.text,');
          }

          ///[add variables to request]
          for (var function in method.emitSets) {
            cubit.writeln('request : ${function.name},');
          }

          ///[add variables to request]
          for (var function in method.functionSets) {
            cubit.writeln('request : ${function.name},');
          }
          for (var parma in method.parameters) {
            cubit.writeln('request : ${parma.name},');
          }
        }

        cubit.writeln(');');
        cubit.writeln('res.left((failure) {');
        cubit.writeln('emit(state.copyWith(');
        cubit.writeln('type: StateType.errorPopUp,');
        cubit.writeln('message: failure.message,');
        cubit.writeln('));');
        cubit.writeln('});');
        cubit.writeln('res.right((data) {');
        cubit.writeln('if (data.success) {');
        if (hasData) {
          cubit.writeln('if(data.data != null){');
          cubit.writeln('$varName = data.data!;');
          cubit.writeln('}');
        }
        cubit.writeln('emit(state.copyWith(');
        cubit.writeln('message: data.message,');
        cubit.writeln('type: StateType.success,');
        cubit.writeln('));');
        cubit.writeln('} else {');
        cubit.writeln('emit(state.copyWith(');
        cubit.writeln('message: data.message,');
        cubit.writeln('type: StateType.errorPopUp,');
        cubit.writeln('));');
        cubit.writeln('}');
        cubit.writeln('});');
        cubit.writeln('}');

        if (hasTextController) cubit.writeln('}');

        ///[create emit set]
        for (var function in method.emitSets) {
          cubit.writeln(
              'void set${names.firstUpper(function.name)}(${function.type} value){');
          cubit.writeln('${function.name} = value;');
          cubit.writeln('emit(state.copyWith(type: StateType.none));');
          cubit.writeln('}');
        }

        ///[create set function]
        for (var function in method.functionSets) {
          cubit.writeln(
              'void set${names.firstUpper(function.name)}(${function.type} value){');
          cubit.writeln('${function.name} = value;');
          cubit.writeln('}');
        }

        cubit.writeln('}');
      }

      FileManager.save(
        '$path/$cubitType',
        cubit.toString(),
        allowUpdates: true,
      );
      cubits.writeln(cubit);
    }
    return cubits.toString();
  }

  String initVaType(String type) {
    switch (type) {
      case 'String':
        return ' = "";';
      case 'double':
        return ' = 0.0;';
      case 'int':
        return ' = 0;';
      case 'List':
        return ' = [];';
      case 'num':
        return ' = 0;';
      default:
        return "\n";
    }
  }
}
