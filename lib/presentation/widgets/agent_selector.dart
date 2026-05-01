import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../../domain/entities/agent.dart';

/// Agent selector widget
class AgentSelector extends StatefulWidget {
  const AgentSelector({
    Key? key,
    this.onAgentSelected,
  }) : super(key: key);

  final Function(String)? onAgentSelected;

  @override
  State<AgentSelector> createState() => _AgentSelectorState();
}

class _AgentSelectorState extends State<AgentSelector> {
  String? _selectedAgent;
  List<Agent> _agents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    setState(() => _isLoading = true);
    try {
      // For now, use hardcoded agents - will be replaced with API call
      _agents = [
        const Agent(
          name: 'general',
          description: 'General purpose agent',
          mode: 'default',
          builtIn: true,
          tools: {},
        ),
        const Agent(
          name: 'plan',
          description: 'Planning agent',
          mode: 'planning',
          builtIn: true,
          tools: {},
        ),
        const Agent(
          name: 'build',
          description: 'Build agent',
          mode: 'building',
          builtIn: true,
          tools: {},
        ),
      ];
      _selectedAgent = _agents.first.name;
      setState(() {});
    } catch (e) {
          } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectAgent(String agentName) {
    setState(() {
      _selectedAgent = agentName;
    });
    widget.onAgentSelected?.call(agentName);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.smart_toy, size: 20),
      tooltip: 'Select Agent',
      onSelected: _selectAgent,
      itemBuilder: (context) {
        return _agents.map((agent) {
          final isSelected = agent.name == _selectedAgent;
          return PopupMenuItem<String>(
            value: agent.name,
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  size: 18,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agent.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : null,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    Text(
                      agent.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
