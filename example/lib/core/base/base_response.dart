import 'dart:io';
import 'package:eitherx/eitherx.dart';
import 'package:mwidgets/mwidgets.dart';
import 'package:example/core/base/no_params.dart';
import 'package:injectable/injectable.dart';
import 'package:example/core/base/base_use_case.dart';
import 'package:json_annotation/json_annotation.dart';
part 'base_response.g.dart';
 @JsonSerializable(genericArgumentFactories: true)
class BaseResponse<T> {
final T? data;
String message;
bool success;
BaseResponse({
this.data,
required this.message,
required this.success,
});
factory BaseResponse.fromJson(
Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
_$BaseResponseFromJson(json, fromJsonT);
}


