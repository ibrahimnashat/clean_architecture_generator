import 'package:clean_architecture_generator/clean_architecture_generator.dart';
import 'package:clean_architecture_generator/src/models/usecase_model.dart';

class MethodFormat {
  String space = " " * 15;

  String parameters(List<CommendType> parameters) {
    String data = '{';
    for (var para in parameters) {
      data +=
          '${para.isRequired ? "required ${para.type.toString()}" : "${para.type.toString()}?"}  ${para.name.toString()},';
    }
    if (data == '{') {
      return '';
    }
    return "$data }";
  }

  String requestParameters(List<CommendType> parameters) {
    String data = '';
    for (var para in parameters) {
      data += '${para.name.toString()}: request!.${para.name.toString()},';
    }
    return data;
  }

  String passingParameters(List<CommendType> parameters) {
    String data = '';
    for (var para in parameters) {
      data += '${para.name.toString()}: ${para.name.toString()},';
    }
    return data;
  }

  String parametersWithValues(List<CommendType> parameters) {
    String data = '';
    for (var para in parameters) {
      data +=
          '${para.name.toString()}: ${initData(para.type.toString(), para.name.toString())},';
    }
    return data;
  }

  String returnType(String type) {
    return type
        .replaceFirst('Future<', '')
        .replaceFirst('>', '')
        .replaceFirst('?>>', '>?>');
  }

  String returnTypeEntity(String type) {
    return type
        .replaceFirst('Future<', '')
        .replaceFirst('>', '')
        .replaceFirst('?>>', '>?>')
        .replaceFirst("Model", "Entity");
  }

  String responseType(String value) {
    return value
        .replaceFirst('BaseResponse<', "")
        .replaceFirst('>', "")
        .replaceFirst('?', '');
  }

  String baseModelType(String value) {
    return value
        .replaceAll('BaseResponse', "")
        .replaceAll('List', "")
        .replaceAll('>', "")
        .replaceAll('<', "")
        .replaceAll('?', '');
  }

  dynamic initData(String type, String name) {
    if (type == 'String') {
      return '"$name"';
    } else if (type == 'double') {
      return 0.0;
    } else if (type == 'int') {
      return 0;
    } else if (type == 'bool') {
      return false;
    } else if (type == 'num') {
      return 0.0;
    } else if (type.contains("List")) {
      return "const []";
    } else if (type == "File") {
      return "File('')";
    }
  }

  String dataType(ParamDataType type) {
    if (type == ParamDataType.listDouble) {
      return 'List<double>';
    } else if (type == ParamDataType.listInt) {
      return 'List<int>';
    } else if (type == ParamDataType.listString) {
      return 'List<String>';
    } else if (type == ParamDataType.listFile) {
      return 'List<File>';
    } else if (type == ParamDataType.File) {
      return 'File';
    }
    return type.name;
  }
}
