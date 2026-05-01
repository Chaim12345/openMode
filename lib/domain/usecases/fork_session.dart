import 'package:dartz/dartz.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/failures.dart';

/// Fork session from a specific message use case
class ForkSession {
  final DioClient dioClient;

  ForkSession(this.dioClient);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String sessionId,
    required String fromMessageId,
  }) async {
    try {
      final response = await dioClient.post(
        '/session/$sessionId/fork',
        data: {'from_message_id': fromMessageId},
      );

      // Extract data from Response object
      final responseData = response.data;
      
      if (responseData is Map<String, dynamic>) {
        return Right(responseData);
      }

      return const Left(ServerFailure('Invalid response format'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
