import 'package:equatable/equatable.dart';

/// Slash command entity
class SlashCommand extends Equatable {
  final String name;
  final String description;
  final String? syntax;

  const SlashCommand({
    required this.name,
    required this.description,
    this.syntax,
  });

  @override
  List<Object?> get props => [name, description, syntax];

  factory SlashCommand.fromJson(Map<String, dynamic> json) {
    return SlashCommand(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      syntax: json['syntax'],
    );
  }
}
