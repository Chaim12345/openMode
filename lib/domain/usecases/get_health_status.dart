import 'package:dartz/dartz.dart';
import '../../core/network/dio_client.dart';
import '../entities/health_status.dart';
import '../../core/errors/failures.dart';

/// Get server health status use case
class GetHealthStatus {
  final DioClient dioClient;

  GetHealthStatus(this.dioClient);

  Future<Either<Failure, HealthStatus>> call() async {
    try {
      final response = await dioClient.get('/global/health');
      
      if (response is HealthStatus) {
        return Right(response);
      }
      
      return const Left(ServerFailure('Invalid response format'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
