import 'dart:io';
import 'package:eitherx/eitherx.dart';
import 'package:mwidgets/mwidgets.dart';
import 'package:example/core/base/base_response.dart';
import 'package:example/core/base/no_params.dart';
import 'package:injectable/injectable.dart';
import 'package:example/core/base/base_use_case.dart';
import 'package:example/core/base/safe_request_handler.dart';
import 'package:example/home/data/models/governorate_model.dart';
import 'package:example/home/data/models/result_model.dart';
import 'package:example/home/data/models/device_settings_model.dart';

///[Implementation]
abstract class HomeRemoteDataSource {
Future<Either<Failure, BaseResponse<List<GovernorateModel>?>>> getGovernorates();
Future<Either<Failure, BaseResponse<ResultModel?>>> getResult({required int  countryId,int?  termId,String?  studentName,String?  sittingNumber, });
Future<Either<Failure, BaseResponse<int>>> addFavorite({required int  countryId, });
Future<Either<Failure, BaseResponse<DeviceSettingsModel?>>> updateUser({required int  firebaseToken, });
}

