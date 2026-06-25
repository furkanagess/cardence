/// Graph kenar tipleri. Bkz. docs/PRICING_NETWORK_GRAPH_THEORY.md §3.
enum GraphEdgeType {
  owns,
  saved,
  scanned,
  viewed,
  contactClicked,
  worksAt,
  metAtEvent,
  coSaved,
  sameCompany,
  assignedLead,
  orgEventLink,
}

extension GraphEdgeTypeX on GraphEdgeType {
  static GraphEdgeType? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    final normalized = value.trim().toLowerCase();
    for (final edge in GraphEdgeType.values) {
      final snake = edge.name.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (m) => '_${m.group(0)!.toLowerCase()}',
      );
      if (snake == normalized || edge.name.toLowerCase() == normalized) {
        return edge;
      }
    }
    return null;
  }
}
