enum MethodType { POST, GET, DELETE, PATCH, POST_MULTI_PART }

enum RequestType { Fields, Body }

enum ParamType { Filed, Query, Path }

enum ParamProp { none, Set, EmitSet, TextController }

enum ParamDataType { String, Int, Num, List }

class CleanMethod {
  final String name;
  final String response;
  final String endPoint;
  final MethodType methodType;
  final RequestType requestType;
  final List<Param> parameters;
  final bool isPaging, isCache;

  const CleanMethod({
    required this.name,
    required this.endPoint,
    required this.response,
    this.methodType = MethodType.POST,
    this.requestType = RequestType.Fields,
    this.isCache = false,
    this.isPaging = false,
    this.parameters = const [],
  });
}

class CleanMethodModel extends CleanMethod {
  CleanMethodModel({
    required super.name,
    required super.endPoint,
    required super.response,
    super.isCache,
    super.isPaging,
    super.methodType,
    super.parameters,
    super.requestType,
  });

  factory CleanMethodModel.fromJson(Map<String, dynamic> map) {
    final methodTypeIndex = MethodType.values
        .indexWhere((element) => element.name == map['methodType']);
    final requestTypeIndex = RequestType.values
        .indexWhere((element) => element.name == map['requestType']);

    final methodType =
        MethodType.values[methodTypeIndex == -1 ? 0 : methodTypeIndex];
    final requestType =
        RequestType.values[requestTypeIndex == -1 ? 0 : requestTypeIndex];

    List<Param> params = [];
    for (var item in map['parameters'] ?? []) {
      params.add(Param.fromJson(item));
    }

    return CleanMethodModel(
      response: map['response'],
      name: map['name'],
      endPoint: map['endPoint'],
      isPaging: map['isPaging'] ?? false,
      isCache: map['isCache'] ?? false,
      methodType: methodType,
      requestType: requestType,
      parameters: params,
    );
  }
}

class Param {
  final String name;
  final ParamType type;
  final ParamProp prop;
  final ParamDataType dataType;
  final bool isRequired;

  const Param({
    required this.name,
    this.type = ParamType.Filed,
    this.prop = ParamProp.none,
    this.dataType = ParamDataType.String,
    this.isRequired = true,
  });

  factory Param.fromJson(Map<String, dynamic> json) {
    final typeIndex =
        ParamType.values.indexWhere((element) => element.name == json['type']);
    final propIndex =
        ParamProp.values.indexWhere((element) => element.name == json['prop']);
    final dataTypeIndex = ParamDataType.values
        .indexWhere((element) => element.name == json['dataType']);

    final paramType = ParamType.values[typeIndex == -1 ? 0 : typeIndex];
    final paramProp = ParamProp.values[propIndex == -1 ? 0 : propIndex];
    final dataType =
        ParamDataType.values[dataTypeIndex == -1 ? 0 : dataTypeIndex];

    return Param(
      name: json['name'],
      isRequired: json['isRequired'] ?? true,
      type: paramType,
      prop: paramProp,
      dataType: dataType,
    );
  }
}