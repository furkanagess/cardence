/// Graph dugum tipleri. Bkz. docs/PRICING_NETWORK_GRAPH_THEORY.md §2.
enum GraphNodeType {
  user,
  card,
  company,
  event,
  organization,
  organizationEvent,
  skill,
  location,
}

extension GraphNodeTypeX on GraphNodeType {
  static GraphNodeType? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    final normalized = value.trim().toLowerCase().replaceAll('_', '');
    for (final node in GraphNodeType.values) {
      if (node.name.toLowerCase() == normalized) return node;
    }
    return null;
  }
}
