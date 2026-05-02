import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider_pkg;
import '../providers/app_provider.dart';
import '../../domain/entities/provider.dart';
import '../../core/constants/app_constants.dart';

/// Model/Provider selection page
class ModelPickerPage extends StatefulWidget {
  const ModelPickerPage({super.key});

  @override
  State<ModelPickerPage> createState() => _ModelPickerPageState();
}

class _ModelPickerPageState extends State<ModelPickerPage> {
  String? _selectedProviderId;
  String? _selectedModelId;
  ProvidersResponse? _providersResponse;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    setState(() => _isLoading = true);
    try {
    final appProvider = context.read<AppProvider>();
    final result = await appProvider.getProviders();
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load providers')),
      );
      return;
    }
    // Success - providers loaded
    setState(() {
      _providersResponse = result;
      if (result.providers.isNotEmpty) {
        _selectedProviderId = result.providers.first.id;
        if (result.providers.first.models.isNotEmpty) {
          _selectedModelId = result.providers.first.models.keys.first;
        }
      }
    });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectModel(String providerId, String modelId) {
    setState(() {
      _selectedProviderId = providerId;
      _selectedModelId = modelId;
    });
    
    // Persist selection
    final appProvider = context.read<AppProvider>();
    appProvider.updateSelectedModel(providerId, modelId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: $modelId'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Model'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showModelDetails(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _providersResponse == null
              ? const Center(child: Text('No providers available'))
              : _buildProviderList(),
    );
  }

  Widget _buildProviderList() {
    if (_providersResponse == null) return const SizedBox();

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: _providersResponse!.providers.length,
      itemBuilder: (context, index) {
        final provider = _providersResponse!.providers[index];
        return _buildProviderCard(provider);
      },
    );
  }

  Widget _buildProviderCard(Provider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: ExpansionTile(
        title: Text(
          provider.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          '${provider.models.length} models available',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        children: provider.models.entries.map((entry) {
          final model = entry.value;
          final isSelected = _selectedModelId == model.id;
          return ListTile(
            leading: Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Text(
              model.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : null,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Context: ${model.limit.context} tokens'),
                if (model.cost.input > 0)
                  Text('Cost: \$${model.cost.input}/1M input'),
              ],
            ),
            onTap: () => _selectModel(provider.id, model.id),
          );
        }).toList(),
      ),
    );
  }

  void _showModelDetails() {
    if (_providersResponse == null || _selectedModelId == null) return;

    final model = _providersResponse!.providers
        .expand((p) => p.models.values)
        .firstWhere(
          (m) => m.id == _selectedModelId,
          orElse: () => throw Exception('Model not found'),
        );

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              model.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Release Date', model.releaseDate),
            _buildDetailRow(
                'Context Window', '${model.limit.context} tokens'),
            _buildDetailRow('Output Limit', '${model.limit.output} tokens'),
            _buildDetailRow(
                'Input Cost', '\$${model.cost.input} per 1M tokens'),
            _buildDetailRow(
                'Output Cost', '\$${model.cost.output} per 1M tokens'),
            _buildDetailRow(
                'Supports Temperature', model.temperature ? 'Yes' : 'No'),
            _buildDetailRow('Supports Tools', model.toolCall ? 'Yes' : 'No'),
            _buildDetailRow(
                'Supports Reasoning', model.reasoning ? 'Yes' : 'No'),
            if (model.openWeights != null)
              _buildDetailRow(
                  'Open Weights', model.openWeights! ? 'Yes' : 'No'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
