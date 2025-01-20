library clean_architecture_generator;

import 'package:build/build.dart';
import 'package:clean_architecture_generator/src/generators/paging_cubit_generator.dart';
import 'package:clean_architecture_generator/src/generators/test/paging_cubit_test_generator.dart';
import 'package:source_gen/source_gen.dart';

import 'src/generators/cache_cubit_generator.dart';
import 'src/generators/cache_usecase_generator.dart';
import 'src/generators/cubit_generator.dart';
import 'src/generators/local_data_source_generator.dart';
import 'src/generators/optimize/entities_generator.dart';
import 'src/generators/optimize/models_generator.dart';
import 'src/generators/optimize/move_models_generator.dart';
import 'src/generators/optimize/optimize_generator.dart';
import 'src/generators/remote_data_source_generator.dart';
import 'src/generators/repository_generator.dart';
import 'src/generators/requests_generator.dart';
import 'src/generators/retrofit_generator.dart';
import 'src/generators/test/cache_cubit_test_generator.dart';
import 'src/generators/test/cache_usecase_test_generator.dart';
import 'src/generators/test/cubit_test_generator.dart';
import 'src/generators/test/get_cache_usecase_test_generator.dart';
import 'src/generators/test/local_data_source_test_generator.dart';
import 'src/generators/test/remote_data_source_test_generator.dart';
import 'src/generators/test/repository_test_generator.dart';
import 'src/generators/test/usecase_test_generator.dart';
import 'src/generators/usecase_generator.dart';

export 'src/annotations.dart';
export 'src/clean_architecture_set_up.dart';
export 'src/models/clean_method.dart';

Builder generateCleanArchitecture(BuilderOptions options) => SharedPartBuilder(
      [
        EntitiesGenerator(),
        ModelsGenerator(),
        MoveModelsGenerator(),
        OptimizeGenerator(),
        RequestsGenerator(),
        RetrofitGenerator(),

        ///[RemoteDataSource]
        RemoteDataSourceGenerator(),
        RemoteDataSourceTestGenerator(),

        ///[LocalDataSource]
        LocalDataSourceGenerator(),
        LocalDataSourceTestGenerator(),

        ///[Repository]
        RepositoryGenerator(),
        RepositoryTestGenerator(),

        ///[UseCase]
        UseCaseGenerator(),
        UseCaseTestGenerator(),

        ///[Cubit]
        CubitGenerator(),
        PagingCubitGenerator(),
        CubitTestGenerator(),
        PagingCubitTestGenerator(),

        ///[CacheUseCase]
        CacheUseCaseGenerator(),
        CacheUseCaseTestGenerator(),
        GetCacheUseCaseTestGenerator(),

        ///[CacheCubit]
        CacheCubitGenerator(),
        CacheCubitTestGenerator(),
      ],
      'clean_architecture',
      formatOutput: (code) {
        return '#BUILD DONE SUCCESSFULLY';
      },
    );
