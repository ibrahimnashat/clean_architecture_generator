import 'package:eitherx/eitherx.dart';
import 'package:example/core/failure.dart';
import 'package:example/core/network.dart';
import 'package:example/core/print.dart';
import 'package:injectable/injectable.dart';

///[SafeApi]
///[Implementation]
@injectable
class SafeApi {
  final NetworkInfo networkInfo;

  SafeApi(this.networkInfo);

  Future<Either<Failure, T>> call<T>({
    required Future<T> apiCall,
  }) async {
    final hasConnection = await networkInfo.isConnected;
    if (hasConnection) {
      try {
        final response = await apiCall;
        return Right(response);
      } catch (error) {
        kPrint("API Error: $error");
        return Left(Failure(600, error.toString()));
      }
    } else {
      return Left(Failure(500, 'No Internet'));
    }
  }
}
