const flowState = 'FlowState';

const loadingState = 'state.copyWith(type: StateType.loadingPopUp)';

const contentState = 'state.copyWith(type: StateType.none)';

const successState =
    'state.copyWith(type: StateType.success,message: data.message,)';

const errorState =
    'state.copyWith(type: StateType.errorPopUp,message: data.message,)';

const errorFailureState =
    'state.copyWith(type: StateType.error,message: failure.message,)';

const successStateTest =
    'state.copyWith(type: StateType.success,message: "message",)';

const errorStateTest =
    'state.copyWith(type: StateType.errorPopUp,message: "message",)';
