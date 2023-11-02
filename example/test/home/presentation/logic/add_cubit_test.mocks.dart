// Mocks generated by Mockito 5.4.2 from annotations
// in example/test/home/presentation/logic/add_cubit_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i12;
import 'dart:ui' as _i10;

import 'package:eitherx/eitherx.dart' as _i8;
import 'package:example/core/base/base_response.dart' as _i14;
import 'package:example/home/domain/entities/device_settings_entity.dart'
    as _i15;
import 'package:example/home/domain/repository/home_repository.dart' as _i7;
import 'package:example/home/domain/requests/add_comment2_request.dart' as _i18;
import 'package:example/home/domain/requests/add_comment_request.dart' as _i16;
import 'package:example/home/domain/use-cases/add_comment2_use_case.dart'
    as _i17;
import 'package:example/home/domain/use-cases/add_comment_use_case.dart'
    as _i11;
import 'package:flutter/foundation.dart' as _i4;
import 'package:flutter/rendering.dart' as _i2;
import 'package:flutter/services.dart' as _i3;
import 'package:flutter/src/widgets/editable_text.dart' as _i9;
import 'package:flutter/src/widgets/form.dart' as _i5;
import 'package:flutter/src/widgets/framework.dart' as _i6;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mwidgets/mwidgets.dart' as _i13;

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

class _FakeTextSelection_0 extends _i1.SmartFake implements _i2.TextSelection {
  _FakeTextSelection_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTextEditingValue_1 extends _i1.SmartFake
    implements _i3.TextEditingValue {
  _FakeTextEditingValue_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeTextSpan_2 extends _i1.SmartFake implements _i2.TextSpan {
  _FakeTextSpan_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );

  @override
  String toString({_i4.DiagnosticLevel? minLevel = _i4.DiagnosticLevel.info}) =>
      super.toString();
}

class _FakeForm_3 extends _i1.SmartFake implements _i5.Form {
  _FakeForm_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );

  @override
  String toString({_i4.DiagnosticLevel? minLevel = _i4.DiagnosticLevel.info}) =>
      super.toString();
}

class _FakeBuildContext_4 extends _i1.SmartFake implements _i6.BuildContext {
  _FakeBuildContext_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWidget_5 extends _i1.SmartFake implements _i6.Widget {
  _FakeWidget_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );

  @override
  String toString({_i4.DiagnosticLevel? minLevel = _i4.DiagnosticLevel.info}) =>
      super.toString();
}

class _FakeDiagnosticsNode_6 extends _i1.SmartFake
    implements _i4.DiagnosticsNode {
  _FakeDiagnosticsNode_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );

  @override
  String toString({
    _i4.TextTreeConfiguration? parentConfiguration,
    _i4.DiagnosticLevel? minLevel = _i4.DiagnosticLevel.info,
  }) =>
      super.toString();
}

class _FakeHomeRepository_7 extends _i1.SmartFake
    implements _i7.HomeRepository {
  _FakeHomeRepository_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeEither_8<L, R> extends _i1.SmartFake implements _i8.Either<L, R> {
  _FakeEither_8(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [TextEditingController].
///
/// See the documentation for Mockito's code generation for more information.
class MockTextEditingController extends _i1.Mock
    implements _i9.TextEditingController {
  @override
  String get text => (super.noSuchMethod(
        Invocation.getter(#text),
        returnValue: '',
        returnValueForMissingStub: '',
      ) as String);
  @override
  set text(String? newText) => super.noSuchMethod(
        Invocation.setter(
          #text,
          newText,
        ),
        returnValueForMissingStub: null,
      );
  @override
  set value(_i3.TextEditingValue? newValue) => super.noSuchMethod(
        Invocation.setter(
          #value,
          newValue,
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i2.TextSelection get selection => (super.noSuchMethod(
        Invocation.getter(#selection),
        returnValue: _FakeTextSelection_0(
          this,
          Invocation.getter(#selection),
        ),
        returnValueForMissingStub: _FakeTextSelection_0(
          this,
          Invocation.getter(#selection),
        ),
      ) as _i2.TextSelection);
  @override
  set selection(_i2.TextSelection? newSelection) => super.noSuchMethod(
        Invocation.setter(
          #selection,
          newSelection,
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i3.TextEditingValue get value => (super.noSuchMethod(
        Invocation.getter(#value),
        returnValue: _FakeTextEditingValue_1(
          this,
          Invocation.getter(#value),
        ),
        returnValueForMissingStub: _FakeTextEditingValue_1(
          this,
          Invocation.getter(#value),
        ),
      ) as _i3.TextEditingValue);
  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);
  @override
  _i2.TextSpan buildTextSpan({
    required _i6.BuildContext? context,
    _i2.TextStyle? style,
    required bool? withComposing,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #buildTextSpan,
          [],
          {
            #context: context,
            #style: style,
            #withComposing: withComposing,
          },
        ),
        returnValue: _FakeTextSpan_2(
          this,
          Invocation.method(
            #buildTextSpan,
            [],
            {
              #context: context,
              #style: style,
              #withComposing: withComposing,
            },
          ),
        ),
        returnValueForMissingStub: _FakeTextSpan_2(
          this,
          Invocation.method(
            #buildTextSpan,
            [],
            {
              #context: context,
              #style: style,
              #withComposing: withComposing,
            },
          ),
        ),
      ) as _i2.TextSpan);
  @override
  void clear() => super.noSuchMethod(
        Invocation.method(
          #clear,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void clearComposing() => super.noSuchMethod(
        Invocation.method(
          #clearComposing,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  bool isSelectionWithinTextBounds(_i2.TextSelection? selection) =>
      (super.noSuchMethod(
        Invocation.method(
          #isSelectionWithinTextBounds,
          [selection],
        ),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);
  @override
  void addListener(_i10.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void removeListener(_i10.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #removeListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(
          #notifyListeners,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [GlobalKey].
///
/// See the documentation for Mockito's code generation for more information.
class MockGlobalKey extends _i1.Mock implements _i6.GlobalKey<_i5.FormState> {}

/// A class which mocks [FormState].
///
/// See the documentation for Mockito's code generation for more information.
class MockFormState extends _i1.Mock implements _i5.FormState {
  @override
  _i5.Form get widget => (super.noSuchMethod(
        Invocation.getter(#widget),
        returnValue: _FakeForm_3(
          this,
          Invocation.getter(#widget),
        ),
        returnValueForMissingStub: _FakeForm_3(
          this,
          Invocation.getter(#widget),
        ),
      ) as _i5.Form);
  @override
  _i6.BuildContext get context => (super.noSuchMethod(
        Invocation.getter(#context),
        returnValue: _FakeBuildContext_4(
          this,
          Invocation.getter(#context),
        ),
        returnValueForMissingStub: _FakeBuildContext_4(
          this,
          Invocation.getter(#context),
        ),
      ) as _i6.BuildContext);
  @override
  bool get mounted => (super.noSuchMethod(
        Invocation.getter(#mounted),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);
  @override
  _i6.Widget build(_i6.BuildContext? context) => (super.noSuchMethod(
        Invocation.method(
          #build,
          [context],
        ),
        returnValue: _FakeWidget_5(
          this,
          Invocation.method(
            #build,
            [context],
          ),
        ),
        returnValueForMissingStub: _FakeWidget_5(
          this,
          Invocation.method(
            #build,
            [context],
          ),
        ),
      ) as _i6.Widget);
  @override
  void save() => super.noSuchMethod(
        Invocation.method(
          #save,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void reset() => super.noSuchMethod(
        Invocation.method(
          #reset,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  bool validate() => (super.noSuchMethod(
        Invocation.method(
          #validate,
          [],
        ),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);
  @override
  void initState() => super.noSuchMethod(
        Invocation.method(
          #initState,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void didUpdateWidget(_i5.Form? oldWidget) => super.noSuchMethod(
        Invocation.method(
          #didUpdateWidget,
          [oldWidget],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void reassemble() => super.noSuchMethod(
        Invocation.method(
          #reassemble,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void setState(_i10.VoidCallback? fn) => super.noSuchMethod(
        Invocation.method(
          #setState,
          [fn],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void deactivate() => super.noSuchMethod(
        Invocation.method(
          #deactivate,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void activate() => super.noSuchMethod(
        Invocation.method(
          #activate,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void didChangeDependencies() => super.noSuchMethod(
        Invocation.method(
          #didChangeDependencies,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void debugFillProperties(_i4.DiagnosticPropertiesBuilder? properties) =>
      super.noSuchMethod(
        Invocation.method(
          #debugFillProperties,
          [properties],
        ),
        returnValueForMissingStub: null,
      );
  @override
  String toString({_i4.DiagnosticLevel? minLevel = _i4.DiagnosticLevel.info}) =>
      super.toString();
  @override
  String toStringShort() => (super.noSuchMethod(
        Invocation.method(
          #toStringShort,
          [],
        ),
        returnValue: '',
        returnValueForMissingStub: '',
      ) as String);
  @override
  _i4.DiagnosticsNode toDiagnosticsNode({
    String? name,
    _i4.DiagnosticsTreeStyle? style,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #toDiagnosticsNode,
          [],
          {
            #name: name,
            #style: style,
          },
        ),
        returnValue: _FakeDiagnosticsNode_6(
          this,
          Invocation.method(
            #toDiagnosticsNode,
            [],
            {
              #name: name,
              #style: style,
            },
          ),
        ),
        returnValueForMissingStub: _FakeDiagnosticsNode_6(
          this,
          Invocation.method(
            #toDiagnosticsNode,
            [],
            {
              #name: name,
              #style: style,
            },
          ),
        ),
      ) as _i4.DiagnosticsNode);
}

/// A class which mocks [AddCommentUseCase].
///
/// See the documentation for Mockito's code generation for more information.
class MockAddCommentUseCase extends _i1.Mock implements _i11.AddCommentUseCase {
  @override
  _i7.HomeRepository get repository => (super.noSuchMethod(
        Invocation.getter(#repository),
        returnValue: _FakeHomeRepository_7(
          this,
          Invocation.getter(#repository),
        ),
        returnValueForMissingStub: _FakeHomeRepository_7(
          this,
          Invocation.getter(#repository),
        ),
      ) as _i7.HomeRepository);
  @override
  _i12
      .Future<
          _i8
          .Either<_i13.Failure, _i14.BaseResponse<_i15.DeviceSettingsEntity?>>>
      execute({_i16.AddCommentRequest? request}) => (super.noSuchMethod(
            Invocation.method(
              #execute,
              [],
              {#request: request},
            ),
            returnValue: _i12.Future<
                    _i8.Either<_i13.Failure,
                        _i14.BaseResponse<_i15.DeviceSettingsEntity?>>>.value(
                _FakeEither_8<_i13.Failure,
                    _i14.BaseResponse<_i15.DeviceSettingsEntity?>>(
              this,
              Invocation.method(
                #execute,
                [],
                {#request: request},
              ),
            )),
            returnValueForMissingStub: _i12.Future<
                    _i8.Either<_i13.Failure,
                        _i14.BaseResponse<_i15.DeviceSettingsEntity?>>>.value(
                _FakeEither_8<_i13.Failure,
                    _i14.BaseResponse<_i15.DeviceSettingsEntity?>>(
              this,
              Invocation.method(
                #execute,
                [],
                {#request: request},
              ),
            )),
          ) as _i12.Future<
              _i8.Either<_i13.Failure,
                  _i14.BaseResponse<_i15.DeviceSettingsEntity?>>>);
}

/// A class which mocks [AddComment2UseCase].
///
/// See the documentation for Mockito's code generation for more information.
class MockAddComment2UseCase extends _i1.Mock
    implements _i17.AddComment2UseCase {
  @override
  _i7.HomeRepository get repository => (super.noSuchMethod(
        Invocation.getter(#repository),
        returnValue: _FakeHomeRepository_7(
          this,
          Invocation.getter(#repository),
        ),
        returnValueForMissingStub: _FakeHomeRepository_7(
          this,
          Invocation.getter(#repository),
        ),
      ) as _i7.HomeRepository);
  @override
  _i12
      .Future<
          _i8
          .Either<_i13.Failure, _i14.BaseResponse<_i15.DeviceSettingsEntity?>>>
      execute({_i18.AddComment2Request? request}) => (super.noSuchMethod(
            Invocation.method(
              #execute,
              [],
              {#request: request},
            ),
            returnValue: _i12.Future<
                    _i8.Either<_i13.Failure,
                        _i14.BaseResponse<_i15.DeviceSettingsEntity?>>>.value(
                _FakeEither_8<_i13.Failure,
                    _i14.BaseResponse<_i15.DeviceSettingsEntity?>>(
              this,
              Invocation.method(
                #execute,
                [],
                {#request: request},
              ),
            )),
            returnValueForMissingStub: _i12.Future<
                    _i8.Either<_i13.Failure,
                        _i14.BaseResponse<_i15.DeviceSettingsEntity?>>>.value(
                _FakeEither_8<_i13.Failure,
                    _i14.BaseResponse<_i15.DeviceSettingsEntity?>>(
              this,
              Invocation.method(
                #execute,
                [],
                {#request: request},
              ),
            )),
          ) as _i12.Future<
              _i8.Either<_i13.Failure,
                  _i14.BaseResponse<_i15.DeviceSettingsEntity?>>>);
}
