const flowState = 'FlowState';

const loadingState = 'const LoadingState(type: LoadingRendererType.popup)';

const contentState = 'const ContentState()';

const successState =
    'SuccessState(type: SuccessRendererType.none,message: data.message,)';

const errorState =
    'ErrorState(type: ErrorRendererType.toast,message: data.message,)';

const errorFailureState =
    'ErrorState(type: ErrorRendererType.toast,message: failure.message,)';

const successStateTest =
    'SuccessState(type: SuccessRendererType.none,message: "message",)';

const errorStateTest =
    'ErrorState(type: ErrorRendererType.toast,message: "message",)';
