import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:clean_architecture_generator/formatter/method_format.dart';
import 'package:clean_architecture_generator/formatter/names.dart';
import 'package:clean_architecture_generator/src/annotations.dart';
import 'package:clean_architecture_generator/src/file_manager.dart';
import 'package:clean_architecture_generator/src/generators/cubit_states.dart';
import 'package:clean_architecture_generator/src/imports_file.dart';
import 'package:clean_architecture_generator/src/models/usecase_model.dart';
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
    final visitor = ModelVisitor();
    element.visitChildren(visitor);

    if (!visitor.isCacheOnly) {
      final path =
          "${FileManager.getDirectories(buildStep.inputId.path)}/presentation/logic";
      final methodFormat = MethodFormat();
      List<String> imports = [];
      for (var method in visitor.useCases) {
        final returnType = methodFormat.returnTypeEntity(method.type);
        final type = methodFormat.baseModelType(returnType);
        imports.add(type);
      }

      List<String> lastCubits = [];
      for (var method in visitor.useCases) {
        List<UseCaseModel> useCases = visitor.useCases
            .where((item) => item.cubitName == method.cubitName)
            .toList();
        if (lastCubits.contains(method.cubitName)) {
          continue;
        }
        if (!method.isPaging) {
          final cubit = StringBuffer();
          List<String> useCasesType = [];
          List<String> requestsType = [];
          for (var useCase in useCases) {
            useCasesType.add(names.useCaseType(useCase.name));
            requestsType.add(names.requestType(useCase.name));
          }

          ///[Imports]
          cubit.writeln(Imports.create(
            imports: [...useCasesType, ...requestsType, ...imports],
            isCubit: true,
          ));

          cubit.writeln('///[${method.cubitName}]');
          cubit.writeln('///[Implementation]');
          cubit.writeln('@injectable');
          cubit
              .writeln('class ${method.cubitName} extends Cubit<$flowState> {');
          for (var useCase in useCases) {
            final useCaseType = names.useCaseType(useCase.name);
            final hasParams = useCase.hasRequest;
            final hasTextController = useCase.hasTextControllers;
            final request = names.requestType(useCase.name);

            cubit.writeln('///[$useCaseType]');
            cubit.writeln(
                'final $useCaseType _${names.firstLower(useCaseType)};');

            if (hasParams)
              cubit.writeln('final $request ${names.firstLower(request)};');

            ///[initialize formKey for validation]
            if (hasTextController) {
              cubit.writeln(
                  'final GlobalKey<FormState> ${names.firstLower(useCase.name)}FormKey;');
            }

            ///[initialize controller for TextEditingController]
            for (var controller in useCase.textControllers) {
              cubit.writeln('final TextEditingController ${controller.name};');
              useCase.parameters
                  .removeWhere((element) => controller.name == element.name);
            }
            cubit.writeln('');
          }

          cubit.writeln('${method.cubitName}(');
          for (var useCase in useCases) {
            final useCaseType = names.useCaseType(useCase.name);
            final hasParams = useCase.hasRequest;
            final hasTextController = useCase.hasTextControllers;
            final request = names.requestType(useCase.name);

            ///[initialize constructor]

            cubit.writeln('this._${names.firstLower(useCaseType)},');
            if (hasTextController) {
              cubit.writeln('this.${names.firstLower(useCase.name)}FormKey,');
            }
            if (hasParams) cubit.writeln('this.${names.firstLower(request)},');
            for (var controller in useCase.textControllers) {
              cubit.writeln('this.${controller.name},');
            }
          }

          cubit.writeln(') : super($contentState);\n');

          for (var useCase in useCases) {
            final useCaseType = names.useCaseType(useCase.name);
            final useCaseName = names.firstLower(useCaseType);
            final varName = names.subName(useCase.name);
            final type = methodFormat.returnTypeEntity(useCase.type);
            final responseType = methodFormat.responseType(type);
            final hasData = !type.contains('BaseResponse<dynamic>');
            final hasTextController = useCase.hasTextControllers;
            final hasFunctionSet = useCase.hasSets;
            final hasEmitSet = useCase.hasEmitSets;
            final request = names.firstLower(names.requestType(useCase.name));

            ///[initialize var for data when cubit is get request]
            if (hasData) {
              if (responseType.contains('List')) {
                cubit.writeln('$responseType $varName = [];');
              } else {
                cubit.writeln('$responseType? $varName;');
              }
            }

            ///[initialize variable for set emit function]
            for (var function in useCase.emitSets) {
              cubit.write(
                  '${function.isRequired ? "${function.type}" : "${function.type}?"} ${function.name}');
              if (function.isRequired) {
                cubit.write(initVaType(function.type));
              } else {
                cubit.write(';');
              }
              useCase.parameters
                  .removeWhere((element) => function.name == element.name);
            }

            ///[initialize variable for set function]
            for (var function in useCase.functionSets) {
              cubit.write(
                  '${function.isRequired ? "${function.type}" : "${function.type}?"} ${function.name}');
              if (function.isRequired) {
                cubit.write(initVaType(function.type));
              } else {
                cubit.write(';');
              }
              useCase.parameters
                  .removeWhere((element) => function.name == element.name);
            }

            cubit.writeln('\n');
            cubit.writeln(
                'Future<void> execute${names.firstUpper(useCase.name)}(${methodFormat.parameters(useCase.parameters)}) async {');
            if (hasTextController) {
              cubit.writeln(
                  'if (${names.firstLower(useCase.name)}FormKey.currentState!.validate()) {');
            }

            ///[add textEditController to request]
            if (hasTextController) {
              for (var controller in useCase.textControllers) {
                if (useCase.hasRequest) {
                  cubit.writeln('$request.${controller.name} =');
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
            }

            ///[add variables to request]
            for (var function in useCase.emitSets) {
              if (useCase.hasRequest) {
                cubit.writeln('$request.${function.name} = ${function.name};');
              }
            }

            ///[add variables to request]
            for (var function in useCase.functionSets) {
              if (useCase.hasRequest) {
                cubit.writeln(
                    '${names.firstLower(request)}.${function.name} = ${function.name};');
              }
            }

            ///[add params to request]
            for (var parma in useCase.parameters) {
              if (useCase.hasRequest) {
                cubit.writeln(
                    '${names.firstLower(request)}.${parma.name} = ${parma.name};');
              }
            }

            cubit.writeln('emit($loadingState);');
            cubit.writeln('final res = await _$useCaseName.execute(');

            ///[add request]
            if (useCase.hasRequest) {
              if (useCase.hasRequest ||
                  hasTextController ||
                  hasFunctionSet ||
                  hasEmitSet) {
                cubit.writeln("request : ${names.firstLower(request)},");
              }
            } else {
              for (var controller in useCase.textControllers) {
                cubit.writeln('request : ${controller.name}.text,');
              }

              ///[add variables to request]
              for (var function in useCase.emitSets) {
                cubit.writeln('request : ${function.name},');
              }

              ///[add variables to request]
              for (var function in useCase.functionSets) {
                cubit.writeln('request : ${function.name},');
              }
              for (var parma in useCase.parameters) {
                cubit.writeln('request : ${parma.name},');
              }
            }

            cubit.writeln(');');
            cubit.writeln('res.left((failure) {');
            cubit.writeln('emit($errorFailureState);');
            cubit.writeln('});');
            cubit.writeln('res.right((data) {');
            cubit.writeln('if (data.success) {');
            if (hasData) {
              cubit.writeln('if(data.data != null){');
              cubit.writeln('$varName = data.data!;');
              cubit.writeln('}');
            }
            cubit.writeln('emit($successState);');
            cubit.writeln('} else {');
            cubit.writeln('emit($errorState);');
            cubit.writeln('}');
            cubit.writeln('});');
            cubit.writeln('}');

            if (hasTextController) cubit.writeln('}');

            ///[create emit set]
            for (var function in useCase.emitSets) {
              cubit.writeln(
                  'void set${names.firstUpper(function.name)}(${function.isRequired ? "${function.type}" : "${function.type}?"} value){');
              cubit.writeln('${function.name} = value;');
              cubit.writeln('emit($contentState);');
              cubit.writeln('}');
            }

            ///[create set function]
            for (var function in useCase.functionSets) {
              cubit.writeln(
                  'void set${names.firstUpper(function.name)}(${function.isRequired ? "${function.type}" : "${function.type}?"} value){');
              cubit.writeln('${function.name} = value;');
              cubit.writeln('}');
            }
          }

          cubit.writeln('}');
          FileManager.save(
            '$path/${method.cubitName}',
            cubit.toString(),
          );
          lastCubits.add(method.cubitName);
        }
      }
    }

    return '';
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
      case 'List<File>':
        return ' = const [];';
      default:
        return ";\n";
    }
  }
}
