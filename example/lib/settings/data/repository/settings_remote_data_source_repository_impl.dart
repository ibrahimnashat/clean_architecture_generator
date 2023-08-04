import 'package:eitherx/eitherx.dart';
import 'package:example/settings/models/base_response.dart';
import 'package:example/settings/models/product_model.dart';
import 'package:example/settings/models/settings_model.dart';
import 'package:example/settings/models/base_response.dart';
import 'package:example/core/failure.dart';
import 'package:injectable/injectable.dart';
import 'package:example/core/base_use_case.dart';
import 'dart:convert';import 'package:example/core/safe_request_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:example/settings/domain/repository/settings_remote_data_source_repository.dart';
import 'package:example/settings/settings_remote_data_source.dart';
import 'package:example/settings/data/data-source/settings_local_data_source.dart';

///[SettingsRemoteDataSourceRepositoryImplement]
///[Implementation]
@Injectable(as:SettingsRemoteDataSourceRepository)
class SettingsRemoteDataSourceRepositoryImplement implements SettingsRemoteDataSourceRepository {
final SettingsRemoteDataSource settingsRemoteDataSource;
final SettingsLocalDataSource settingsLocalDataSource;
final SafeApi api;
const SettingsRemoteDataSourceRepositoryImplement(
this.settingsRemoteDataSource,
this.settingsLocalDataSource,
this.api,
);

@override
Future<Either<Failure, BaseResponse<dynamic>>> saveProduct({required String productId,required String type, })async {
return await api<BaseResponse<dynamic>>(
apiCall: settingsRemoteDataSource.saveProduct(productId: productId,type: type,),);
}

@override
Future<Either<Failure, BaseResponse<List<ProductModel>?>>> getSavedProducts({required int page,required int limit, })async {
return await api<BaseResponse<List<ProductModel>?>>(
apiCall: settingsRemoteDataSource.getSavedProducts(page: page,limit: limit,),);
}

@override
Future<Either<Failure, Unit>> cacheSavedProducts({required List<ProductModel> data,}) async {
return await settingsLocalDataSource.cacheSavedProducts(data: data);
}

@override
Either<Failure, List<ProductModel>> getCacheSavedProducts(){
return settingsLocalDataSource.getCacheSavedProducts();
}

@override
Future<Either<Failure, BaseResponse<SettingsModel?>>> getSettings()async {
return await api<BaseResponse<SettingsModel?>>(
apiCall: settingsRemoteDataSource.getSettings(),);
}

@override
Future<Either<Failure, Unit>> cacheSettings({required SettingsModel data,}) async {
return await settingsLocalDataSource.cacheSettings(data: data);
}

@override
Either<Failure, SettingsModel> getCacheSettings(){
return settingsLocalDataSource.getCacheSettings();
}

@override
Future<Either<Failure, BaseResponse<List<SettingsModel>?>>> getApp({required int page,required int limit, })async {
return await api<BaseResponse<List<SettingsModel>?>>(
apiCall: settingsRemoteDataSource.getApp(page: page,limit: limit,),);
}

@override
Future<Either<Failure, BaseResponse<int>>> getAA()async {
return await api<BaseResponse<int>>(
apiCall: settingsRemoteDataSource.getAA(),);
}

}

