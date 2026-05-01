import 'package:equatable/equatable.dart';

/// File/Directory information entity
class FileInfo extends Equatable {
  final String name;
  final String path;
  final bool isDirectory;
  final int? size;
  final DateTime? modified;
  final List<FileInfo>? children;

  const FileInfo({
    required this.name,
    required this.path,
    required this.isDirectory,
    this.size,
    this.modified,
    this.children,
  });

  @override
  List<Object?> get props => [name, path, isDirectory, size, modified, children];

  FileInfo copyWith({
    String? name,
    String? path,
    bool? isDirectory,
    int? size,
    DateTime? modified,
    List<FileInfo>? children,
  }) {
    return FileInfo(
      name: name ?? this.name,
      path: path ?? this.path,
      isDirectory: isDirectory ?? this.isDirectory,
      size: size ?? this.size,
      modified: modified ?? this.modified,
      children: children ?? this.children,
    );
  }
}
