/// Graph sorgu kapsami. Bkz. docs/PRICING_NETWORK_GRAPH_THEORY.md §6.
enum GraphScope {
  personal,
  event,
  organization,
}

extension GraphScopeX on GraphScope {
  String get apiValue => switch (this) {
        GraphScope.personal => 'personal',
        GraphScope.event => 'event',
        GraphScope.organization => 'organization',
      };
}
