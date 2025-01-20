import 'package:clean_architecture_generator/clean_architecture_generator.dart';

@TDDCleanArchitecture
class Home implements CleanArchitectureSetUp {
  @override
  List<CleanMethod> methods() {
    return [
      const CleanMethod(
        cubitName: 'AddCubit',
        name: 'addComment',
        endPoint: 'sendCode',
        response: 'BaseResponse<DeviceSettingsModel?>',
        methodType: MethodType.POST,
        parameters: [
          Param(
            key: 'story_id',
            name: 'storyId1',
            type: ParamType.Field,
          ),
          Param(
            name: 'content1',
            type: ParamType.Field,
            prop: ParamProp.TextController,
          ),
        ],
      ),
      const CleanMethod(
        cubitName: 'AddCubit',
        name: 'addComment2',
        endPoint: 'sendCode',
        response: 'BaseResponse<DeviceSettingsModel?>',
        methodType: MethodType.POST,
        parameters: [
          Param(
            key: 'story_id',
            name: 'storyId2',
            type: ParamType.Field,
          ),
          Param(
            name: 'content2',
            type: ParamType.Field,
            prop: ParamProp.TextController,
          ),
        ],
      ),
      const CleanMethod(
        cubitName: 'AddCubit3',
        name: 'addComment3',
        endPoint: 'sendCode',
        response: 'BaseResponse<DeviceSettingsModel?>',
        methodType: MethodType.POST,
        parameters: [
          Param(
            key: 'story_id',
            name: 'storyId',
            type: ParamType.Field,
          ),
          Param(
            name: 'content',
            type: ParamType.Field,
            prop: ParamProp.TextController,
          ),
        ],
      ),
      const CleanMethod(
        cubitName: 'AddCubit4',
        name: 'addComment4',
        endPoint: 'sendCode',
        response: 'BaseResponse<DeviceSettingsModel?>',
        methodType: MethodType.POST,
        parameters: [
          Param(
            key: 'story_id',
            name: 'storyId',
            type: ParamType.Field,
          ),
          Param(
            name: 'content',
            type: ParamType.Field,
            prop: ParamProp.TextController,
          ),
        ],
      ),
      const CleanMethod(
        cubitName: 'AddCubit5',
        name: 'addComment5',
        endPoint: 'sendCode',
        isCache: true,
        response: 'BaseResponse<DeviceSettingsModel?>',
        methodType: MethodType.POST,
        parameters: [
          Param(
            key: 'story_id',
            name: 'storyId',
            type: ParamType.Field,
          ),
          Param(
            name: 'content',
            type: ParamType.Field,
            prop: ParamProp.TextController,
          ),
        ],
      ),
      const CleanMethod(
        cubitName: 'AddCubit6',
        name: 'addComment6',
        endPoint: 'sendCode',
        response: 'BaseResponse<DeviceSettingsModel?>',
        methodType: MethodType.POST,
        parameters: [
          Param(
            key: 'story_id',
            name: 'storyId1',
            type: ParamType.Field,
          ),
          Param(
            name: 'content1',
            type: ParamType.Field,
            prop: ParamProp.TextController,
          ),
        ],
      ),
      const CleanMethod(
        cubitName: 'AddCubit6',
        name: 'addComment7',
        endPoint: 'sendCode',
        response: 'BaseResponse<DeviceSettingsModel?>',
        methodType: MethodType.POST,
        parameters: [
          Param(
            key: 'story_id',
            name: 'storyId2',
            type: ParamType.Field,
          ),
          Param(
            name: 'content2',
            type: ParamType.Field,
            prop: ParamProp.TextController,
          ),
        ],
      ),
      const CleanMethod(
        cubitName: 'AddCubit6',
        name: 'addComment8',
        endPoint: 'sendCode',
        response: 'BaseResponse<DeviceSettingsModel?>',
        methodType: MethodType.POST,
        parameters: [
          Param(
            key: 'story_id',
            name: 'storyId3',
            type: ParamType.Field,
          ),
          Param(
            name: 'content3',
            type: ParamType.Field,
            prop: ParamProp.TextController,
          ),
        ],
      ),
    ];
  }
}
