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

      // Extract data from Response object and convert to HealthStatus
      final responseData = response.data;
      
      if (responseData is Map<String, dynamic>) {
        // Assuming HealthStatus has a fromJson or similar constructor
        // We need to check the HealthStatus entity
        return Right(HealthStatus.fromJson(responseData));
      }

      return const Left(ServerFailure('Invalid response format'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
