import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/errors/exceptions.dart';
import '../../core/constants/api_constants.dart';
import '../models/agent_model.dart';

/// Agent remote data source
class AgentRemoteDataSource {
  final http.Client client;
  String baseUrl;

  AgentRemoteDataSource({
    required this.client,
    this.baseUrl = ApiConstants.defaultBaseUrl,
  });

  /// Get all agents from server
  Future<List<AgentModel>> getAgents() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl${ApiConstants.agentEndpoint}'),
        headers: {
          ApiConstants.contentType: ApiConstants.applicationJson,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => AgentModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to get agents: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error getting agents: $e');
    }
  }
}
