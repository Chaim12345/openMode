import 'package:equatable/equatable.dart';

/// Server health status entity
class HealthStatus extends Equatable {
  final String version;
  final bool healthy;
  final String? status;
  final DateTime? timestamp;

  const HealthStatus({
    required this.version,
    required this.healthy,
    this.status,
    this.timestamp,
  });

  @override
  List<Object?> get props => [version, healthy, status, timestamp];

  factory HealthStatus.fromJson(Map<String, dynamic> json) {
    return HealthStatus(
      version: json['version'] ?? 'unknown',
      healthy: json['healthy'] ?? json['status'] == 'ok',
      status: json['status'],
      timestamp: json['timestamp'] != null 
          ? DateTime.tryParse(json['timestamp'].toString()) 
          : null,
    );
  }
}
