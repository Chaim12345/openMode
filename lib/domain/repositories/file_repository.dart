import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/file_info.dart';

/// File repository interface
abstract class FileRepository {
  /// Get files/directories at a specific path
  Future<Either<Failure, List<FileInfo>>> getFiles(String path);
  
  /// Get file content
  Future<Either<Failure, String>> getFileContent(String path);
  
  /// Search files by filename
  Future<Either<Failure, List<FileInfo>>> searchFiles(String query);
  
  /// Search text pattern in files
  Future<Either<Failure, List<FileInfo>>> searchText(String pattern);
}
