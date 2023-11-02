// Mocks generated by Mockito 5.4.2 from annotations
// in example/test/home/presentation/logic/get_cache_add_cubit5_cubit_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ffi' as _i7;

import 'package:eitherx/eitherx.dart' as _i3;
import 'package:example/home/domain/entities/device_settings_entity.dart'
    as _i6;
import 'package:example/home/domain/repository/home_repository.dart' as _i2;
import 'package:example/home/domain/use-cases/get_cache_add_comment5_use_case.dart'
    as _i4;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mwidgets/mwidgets.dart' as _i5;

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

class _FakeHomeRepository_0 extends _i1.SmartFake
    implements _i2.HomeRepository {
  _FakeHomeRepository_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeEither_1<L, R> extends _i1.SmartFake implements _i3.Either<L, R> {
  _FakeEither_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [GetCacheAddComment5UseCase].
///
/// See the documentation for Mockito's code generation for more information.
class MockGetCacheAddComment5UseCase extends _i1.Mock
    implements _i4.GetCacheAddComment5UseCase {
  @override
  _i2.HomeRepository get repository => (super.noSuchMethod(
        Invocation.getter(#repository),
        returnValue: _FakeHomeRepository_0(
          this,
          Invocation.getter(#repository),
        ),
        returnValueForMissingStub: _FakeHomeRepository_0(
          this,
          Invocation.getter(#repository),
        ),
      ) as _i2.HomeRepository);
  @override
  _i3.Either<_i5.Failure, _i6.DeviceSettingsEntity> execute(
          {_i7.Void? request}) =>
      (super.noSuchMethod(
        Invocation.method(
          #execute,
          [],
          {#request: request},
        ),
        returnValue: _FakeEither_1<_i5.Failure, _i6.DeviceSettingsEntity>(
          this,
          Invocation.method(
            #execute,
            [],
            {#request: request},
          ),
        ),
        returnValueForMissingStub:
            _FakeEither_1<_i5.Failure, _i6.DeviceSettingsEntity>(
          this,
          Invocation.method(
            #execute,
            [],
            {#request: request},
          ),
        ),
      ) as _i3.Either<_i5.Failure, _i6.DeviceSettingsEntity>);
}
