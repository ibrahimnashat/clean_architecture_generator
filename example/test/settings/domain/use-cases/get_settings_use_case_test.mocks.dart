// Mocks generated by Mockito 5.4.2 from annotations
// in example/test/settings/domain/use-cases/get_settings_use_case_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:eitherx/eitherx.dart' as _i2;
import 'package:example/core/failure.dart' as _i5;
import 'package:example/settings/domain/repository/settings_remote_data_source_repository.dart'
    as _i3;
import 'package:example/settings/models/base_response.dart' as _i6;
import 'package:example/settings/models/product_model.dart' as _i7;
import 'package:example/settings/models/settings_model.dart' as _i8;
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

class _FakeEither_0<L, R> extends _i1.SmartFake implements _i2.Either<L, R> {
  _FakeEither_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [SettingsRemoteDataSourceRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockSettingsRemoteDataSourceRepository extends _i1.Mock
    implements _i3.SettingsRemoteDataSourceRepository {
  @override
  _i4.Future<_i2.Either<_i5.Failure, _i6.BaseResponse<dynamic>>> saveProduct({
    required String? productId,
    required String? type,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveProduct,
          [],
          {
            #productId: productId,
            #type: type,
          },
        ),
        returnValue: _i4
            .Future<_i2.Either<_i5.Failure, _i6.BaseResponse<dynamic>>>.value(
            _FakeEither_0<_i5.Failure, _i6.BaseResponse<dynamic>>(
          this,
          Invocation.method(
            #saveProduct,
            [],
            {
              #productId: productId,
              #type: type,
            },
          ),
        )),
        returnValueForMissingStub: _i4
            .Future<_i2.Either<_i5.Failure, _i6.BaseResponse<dynamic>>>.value(
            _FakeEither_0<_i5.Failure, _i6.BaseResponse<dynamic>>(
          this,
          Invocation.method(
            #saveProduct,
            [],
            {
              #productId: productId,
              #type: type,
            },
          ),
        )),
      ) as _i4.Future<_i2.Either<_i5.Failure, _i6.BaseResponse<dynamic>>>);
  @override
  _i4.Future<_i2.Either<_i5.Failure, _i6.BaseResponse<List<_i7.ProductModel>?>>>
      getSavedProducts({
    required int? page,
    required int? limit,
  }) =>
          (super.noSuchMethod(
            Invocation.method(
              #getSavedProducts,
              [],
              {
                #page: page,
                #limit: limit,
              },
            ),
            returnValue: _i4.Future<
                    _i2.Either<_i5.Failure,
                        _i6.BaseResponse<List<_i7.ProductModel>?>>>.value(
                _FakeEither_0<_i5.Failure,
                    _i6.BaseResponse<List<_i7.ProductModel>?>>(
              this,
              Invocation.method(
                #getSavedProducts,
                [],
                {
                  #page: page,
                  #limit: limit,
                },
              ),
            )),
            returnValueForMissingStub: _i4.Future<
                    _i2.Either<_i5.Failure,
                        _i6.BaseResponse<List<_i7.ProductModel>?>>>.value(
                _FakeEither_0<_i5.Failure,
                    _i6.BaseResponse<List<_i7.ProductModel>?>>(
              this,
              Invocation.method(
                #getSavedProducts,
                [],
                {
                  #page: page,
                  #limit: limit,
                },
              ),
            )),
          ) as _i4.Future<
              _i2
              .Either<_i5.Failure, _i6.BaseResponse<List<_i7.ProductModel>?>>>);
  @override
  _i4.Future<_i2.Either<_i5.Failure, _i2.Unit>> cacheSavedProducts(
          {required List<_i7.ProductModel>? data}) =>
      (super.noSuchMethod(
        Invocation.method(
          #cacheSavedProducts,
          [],
          {#data: data},
        ),
        returnValue: _i4.Future<_i2.Either<_i5.Failure, _i2.Unit>>.value(
            _FakeEither_0<_i5.Failure, _i2.Unit>(
          this,
          Invocation.method(
            #cacheSavedProducts,
            [],
            {#data: data},
          ),
        )),
        returnValueForMissingStub:
            _i4.Future<_i2.Either<_i5.Failure, _i2.Unit>>.value(
                _FakeEither_0<_i5.Failure, _i2.Unit>(
          this,
          Invocation.method(
            #cacheSavedProducts,
            [],
            {#data: data},
          ),
        )),
      ) as _i4.Future<_i2.Either<_i5.Failure, _i2.Unit>>);
  @override
  _i2.Either<_i5.Failure, List<_i7.ProductModel>> getCacheSavedProducts() =>
      (super.noSuchMethod(
        Invocation.method(
          #getCacheSavedProducts,
          [],
        ),
        returnValue: _FakeEither_0<_i5.Failure, List<_i7.ProductModel>>(
          this,
          Invocation.method(
            #getCacheSavedProducts,
            [],
          ),
        ),
        returnValueForMissingStub:
            _FakeEither_0<_i5.Failure, List<_i7.ProductModel>>(
          this,
          Invocation.method(
            #getCacheSavedProducts,
            [],
          ),
        ),
      ) as _i2.Either<_i5.Failure, List<_i7.ProductModel>>);
  @override
  _i4.Future<
      _i2.Either<_i5.Failure,
          _i6.BaseResponse<_i8.SettingsModel?>>> getSettings() =>
      (super.noSuchMethod(
        Invocation.method(
          #getSettings,
          [],
        ),
        returnValue: _i4.Future<
                _i2.Either<_i5.Failure,
                    _i6.BaseResponse<_i8.SettingsModel?>>>.value(
            _FakeEither_0<_i5.Failure, _i6.BaseResponse<_i8.SettingsModel?>>(
          this,
          Invocation.method(
            #getSettings,
            [],
          ),
        )),
        returnValueForMissingStub: _i4.Future<
                _i2.Either<_i5.Failure,
                    _i6.BaseResponse<_i8.SettingsModel?>>>.value(
            _FakeEither_0<_i5.Failure, _i6.BaseResponse<_i8.SettingsModel?>>(
          this,
          Invocation.method(
            #getSettings,
            [],
          ),
        )),
      ) as _i4.Future<
          _i2.Either<_i5.Failure, _i6.BaseResponse<_i8.SettingsModel?>>>);
  @override
  _i4.Future<_i2.Either<_i5.Failure, _i2.Unit>> cacheSettings(
          {required _i8.SettingsModel? data}) =>
      (super.noSuchMethod(
        Invocation.method(
          #cacheSettings,
          [],
          {#data: data},
        ),
        returnValue: _i4.Future<_i2.Either<_i5.Failure, _i2.Unit>>.value(
            _FakeEither_0<_i5.Failure, _i2.Unit>(
          this,
          Invocation.method(
            #cacheSettings,
            [],
            {#data: data},
          ),
        )),
        returnValueForMissingStub:
            _i4.Future<_i2.Either<_i5.Failure, _i2.Unit>>.value(
                _FakeEither_0<_i5.Failure, _i2.Unit>(
          this,
          Invocation.method(
            #cacheSettings,
            [],
            {#data: data},
          ),
        )),
      ) as _i4.Future<_i2.Either<_i5.Failure, _i2.Unit>>);
  @override
  _i2.Either<_i5.Failure, _i8.SettingsModel> getCacheSettings() =>
      (super.noSuchMethod(
        Invocation.method(
          #getCacheSettings,
          [],
        ),
        returnValue: _FakeEither_0<_i5.Failure, _i8.SettingsModel>(
          this,
          Invocation.method(
            #getCacheSettings,
            [],
          ),
        ),
        returnValueForMissingStub:
            _FakeEither_0<_i5.Failure, _i8.SettingsModel>(
          this,
          Invocation.method(
            #getCacheSettings,
            [],
          ),
        ),
      ) as _i2.Either<_i5.Failure, _i8.SettingsModel>);
  @override
  _i4.Future<_i2.Either<_i5.Failure, _i6.BaseResponse<dynamic>>> getApp({
    required int? page,
    required int? limit,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #getApp,
          [],
          {
            #page: page,
            #limit: limit,
          },
        ),
        returnValue: _i4
            .Future<_i2.Either<_i5.Failure, _i6.BaseResponse<dynamic>>>.value(
            _FakeEither_0<_i5.Failure, _i6.BaseResponse<dynamic>>(
          this,
          Invocation.method(
            #getApp,
            [],
            {
              #page: page,
              #limit: limit,
            },
          ),
        )),
        returnValueForMissingStub: _i4
            .Future<_i2.Either<_i5.Failure, _i6.BaseResponse<dynamic>>>.value(
            _FakeEither_0<_i5.Failure, _i6.BaseResponse<dynamic>>(
          this,
          Invocation.method(
            #getApp,
            [],
            {
              #page: page,
              #limit: limit,
            },
          ),
        )),
      ) as _i4.Future<_i2.Either<_i5.Failure, _i6.BaseResponse<dynamic>>>);
}
