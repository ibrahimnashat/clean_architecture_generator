import 'clean_method.dart';

class UseCaseModel {
  final String type;
  final String name;
  final String cubitName;
  final String endPoint;
  final MethodType methodType;
  final RequestType requestType;
  final List<CommendType> parameters;
  final bool isPaging, isCache;
  final List<Param> requestParameters;
  List<CommendType> functionSets = [];
  List<CommendType> emitSets = [];
  List<CommendType> textControllers = [];

  bool get hasRequest =>
      (requestParameters.length > 1 && requestType == RequestType.Fields) ||
      requestType == RequestType.Body;

  bool get hasTextControllers => textControllers.isNotEmpty;

  bool get hasSets => functionSets.isNotEmpty;

  bool get hasEmitSets => emitSets.isNotEmpty;

  UseCaseModel({
    required this.type,
    required this.name,
    required this.endPoint,
    required this.parameters,
    required this.isPaging,
    required this.isCache,
    required this.functionSets,
    required this.textControllers,
    required this.emitSets,
    required this.requestParameters,
    required this.cubitName,
    this.methodType = MethodType.POST,
    this.requestType = RequestType.Fields,
  });
}

class CommendType {
  final String type;
  final String name;
  final bool isRequired;

  const CommendType({
    required this.name,
    required this.type,
    this.isRequired = true,
  });
}
