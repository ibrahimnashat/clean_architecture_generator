import 'package:eitherx/eitherx.dart';
import 'package:example/core/consts/constants.dart';
import 'package:example/core/cubit/base_response/base_response.dart';
import 'package:example/core/cubit/base_response/base_response.dart';
import 'package:example/core/failure.dart';
import 'package:injectable/injectable.dart';
import 'package:example/core/base_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:example/core/cubit/state_renderer/states.dart';
import 'package:example/core/consts/fold.dart';
import 'package:example/core/cubit/state_renderer/state_renderer.dart';
import 'package:example/test/repository/use-cases/get_sengs_use_case.dart';

///[GetSengsCubit]
///[Implementation]
@injectable
class GetSengsCubit extends Cubit<FlowState> {
final GetSengsUseCase _getSengsUseCase;
GetSengsCubit(this._getSengsUseCase,
) : super(ContentState());

InvalidType? sengs;


Future<void> execute() async {
emit(LoadingState(type: StateRendererType.popUpLoading));
final res = await _getSengsUseCase.execute(
)
);
res.left((failure) {
emit(ErrorState(
type: StateRendererType.toastError,
message: failure.message,
));
});
res.right((data) {
if (data.success) {
if(data.data != null){
sengs = data.data!;
}
emit(SuccessState(
message: data.message,
type: StateRendererType.contentState,
));
} else {
emit(SuccessState(
message: data.message,
type: StateRendererType.toastError,
));
}
});
}
}
