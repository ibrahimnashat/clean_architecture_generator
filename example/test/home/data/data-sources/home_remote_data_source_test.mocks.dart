// Mocks generated by Mockito 5.4.2 from annotations
// in example/test/home/data/data-sources/home_remote_data_source_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:example/core/base/base_response.dart' as _i2;
import 'package:example/core/base/network.dart' as _i8;
import 'package:example/home/data/client-services/home_client_services.dart'
    as _i3;
import 'package:example/home/data/models/device_settings_model.dart' as _i7;
import 'package:example/home/data/models/governorate_model.dart' as _i5;
import 'package:example/home/data/models/result_model.dart' as _i6;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeBaseResponse_0<T> extends _i1.SmartFake
    implements _i2.BaseResponse<T> {
  _FakeBaseResponse_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [HomeClientServices].
///
/// See the documentation for Mockito's code generation for more information.
class MockHomeClientServices extends _i1.Mock
    implements _i3.HomeClientServices {
  @override
  _i4.Future<_i2.BaseResponse<List<_i5.GovernorateModel>?>> getGovernorates() =>
      (super.noSuchMethod(
        Invocation.method(
          #getGovernorates,
          [],
        ),
        returnValue:
            _i4.Future<_i2.BaseResponse<List<_i5.GovernorateModel>?>>.value(
                _FakeBaseResponse_0<List<_i5.GovernorateModel>?>(
          this,
          Invocation.method(
            #getGovernorates,
            [],
          ),
        )),
        returnValueForMissingStub:
            _i4.Future<_i2.BaseResponse<List<_i5.GovernorateModel>?>>.value(
                _FakeBaseResponse_0<List<_i5.GovernorateModel>?>(
          this,
          Invocation.method(
            #getGovernorates,
            [],
          ),
        )),
      ) as _i4.Future<_i2.BaseResponse<List<_i5.GovernorateModel>?>>);
  @override
  _i4.Future<_i2.BaseResponse<_i6.ResultModel?>> getResult({
    required int? countryId,
    int? termId,
    String? studentName,
    String? sittingNumber,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #getResult,
          [],
          {
            #countryId: countryId,
            #termId: termId,
            #studentName: studentName,
            #sittingNumber: sittingNumber,
          },
        ),
        returnValue: _i4.Future<_i2.BaseResponse<_i6.ResultModel?>>.value(
            _FakeBaseResponse_0<_i6.ResultModel?>(
          this,
          Invocation.method(
            #getResult,
            [],
            {
              #countryId: countryId,
              #termId: termId,
              #studentName: studentName,
              #sittingNumber: sittingNumber,
            },
          ),
        )),
        returnValueForMissingStub:
            _i4.Future<_i2.BaseResponse<_i6.ResultModel?>>.value(
                _FakeBaseResponse_0<_i6.ResultModel?>(
          this,
          Invocation.method(
            #getResult,
            [],
            {
              #countryId: countryId,
              #termId: termId,
              #studentName: studentName,
              #sittingNumber: sittingNumber,
            },
          ),
        )),
      ) as _i4.Future<_i2.BaseResponse<_i6.ResultModel?>>);
  @override
  _i4.Future<_i2.BaseResponse<int>> addFavorite({required int? countryId}) =>
      (super.noSuchMethod(
        Invocation.method(
          #addFavorite,
          [],
          {#countryId: countryId},
        ),
        returnValue:
            _i4.Future<_i2.BaseResponse<int>>.value(_FakeBaseResponse_0<int>(
          this,
          Invocation.method(
            #addFavorite,
            [],
            {#countryId: countryId},
          ),
        )),
        returnValueForMissingStub:
            _i4.Future<_i2.BaseResponse<int>>.value(_FakeBaseResponse_0<int>(
          this,
          Invocation.method(
            #addFavorite,
            [],
            {#countryId: countryId},
          ),
        )),
      ) as _i4.Future<_i2.BaseResponse<int>>);
  @override
  _i4.Future<_i2.BaseResponse<_i7.DeviceSettingsModel?>> updateUser(
          {required int? firebaseToken}) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateUser,
          [],
          {#firebaseToken: firebaseToken},
        ),
        returnValue:
            _i4.Future<_i2.BaseResponse<_i7.DeviceSettingsModel?>>.value(
                _FakeBaseResponse_0<_i7.DeviceSettingsModel?>(
          this,
          Invocation.method(
            #updateUser,
            [],
            {#firebaseToken: firebaseToken},
          ),
        )),
        returnValueForMissingStub:
            _i4.Future<_i2.BaseResponse<_i7.DeviceSettingsModel?>>.value(
                _FakeBaseResponse_0<_i7.DeviceSettingsModel?>(
          this,
          Invocation.method(
            #updateUser,
            [],
            {#firebaseToken: firebaseToken},
          ),
        )),
      ) as _i4.Future<_i2.BaseResponse<_i7.DeviceSettingsModel?>>);
}

/// A class which mocks [NetworkInfo].
///
/// See the documentation for Mockito's code generation for more information.
class MockNetworkInfo extends _i1.Mock implements _i8.NetworkInfo {
  @override
  _i4.Future<bool> get isConnected => (super.noSuchMethod(
        Invocation.getter(#isConnected),
        returnValue: _i4.Future<bool>.value(false),
        returnValueForMissingStub: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);
}
