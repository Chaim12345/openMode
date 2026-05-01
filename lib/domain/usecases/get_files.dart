import 'package:dartz/dartz.dart';
import '../repositories/file_repository.dart';
import '../entities/file_info.dart';
import '../../core/errors/failures.dart';

/// Get files at a specific path use case
class GetFiles {
  final FileRepository repository;

  GetFiles(this.repository);

  Future<Either<Failure, List<FileInfo>>> call(String path) async {
    return await repository.getFiles(path);
  }
}
