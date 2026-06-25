class PlanFeatures {
  const PlanFeatures({
    this.adsDisabled = false,
    this.advancedDesigns = false,
    this.profileStats = false,
    this.csvExport = false,
    this.networkGraph = false,
    this.walletPass = false,
    this.crmIntegration = false,
  });

  final bool adsDisabled;
  final bool advancedDesigns;
  final bool profileStats;
  final bool csvExport;
  final bool networkGraph;
  final bool walletPass;
  final bool crmIntegration;
}
