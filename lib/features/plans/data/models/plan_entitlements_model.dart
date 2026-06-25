import '../../../../core/network/api_response_parser.dart';
import '../../domain/entities/plan_entitlements.dart';
import '../../domain/entities/plan_features.dart';
import '../../domain/entities/plan_limits.dart';
import '../../domain/entities/plan_tier.dart';

class PlanEntitlementsModel {
  const PlanEntitlementsModel({
    required this.tier,
    required this.features,
    required this.limits,
  });

  final String tier;
  final PlanFeaturesModel features;
  final PlanLimitsModel limits;

  factory PlanEntitlementsModel.fromJson(Map<String, dynamic> json) {
    return PlanEntitlementsModel(
      tier: (json['tier'] ?? json['Tier'] ?? PlanTier.free.name).toString(),
      features: PlanFeaturesModel.fromJson(
        ApiResponseParser.readMap(json['features'] ?? json['Features']) ??
            const <String, dynamic>{},
      ),
      limits: PlanLimitsModel.fromJson(
        ApiResponseParser.readMap(json['limits'] ?? json['Limits']) ??
            const <String, dynamic>{},
      ),
    );
  }

  PlanEntitlements toEntity() {
    return PlanEntitlements(
      tier: PlanTier.fromName(tier),
      features: features.toEntity(),
      limits: limits.toEntity(),
    );
  }
}

class PlanFeaturesModel {
  const PlanFeaturesModel({
    required this.adsDisabled,
    required this.advancedDesigns,
    required this.profileStats,
    required this.csvExport,
    required this.networkGraph,
    required this.walletPass,
    required this.crmIntegration,
  });

  final bool adsDisabled;
  final bool advancedDesigns;
  final bool profileStats;
  final bool csvExport;
  final bool networkGraph;
  final bool walletPass;
  final bool crmIntegration;

  factory PlanFeaturesModel.fromJson(Map<String, dynamic> json) {
    return PlanFeaturesModel(
      adsDisabled: _readBool(json['adsDisabled'] ?? json['AdsDisabled']),
      advancedDesigns:
          _readBool(json['advancedDesigns'] ?? json['AdvancedDesigns']),
      profileStats: _readBool(json['profileStats'] ?? json['ProfileStats']),
      csvExport: _readBool(json['csvExport'] ?? json['CsvExport']),
      networkGraph: _readBool(json['networkGraph'] ?? json['NetworkGraph']),
      walletPass: _readBool(json['walletPass'] ?? json['WalletPass']),
      crmIntegration:
          _readBool(json['crmIntegration'] ?? json['CrmIntegration']),
    );
  }

  PlanFeatures toEntity() {
    return PlanFeatures(
      adsDisabled: adsDisabled,
      advancedDesigns: advancedDesigns,
      profileStats: profileStats,
      csvExport: csvExport,
      networkGraph: networkGraph,
      walletPass: walletPass,
      crmIntegration: crmIntegration,
    );
  }
}

class PlanLimitsModel {
  const PlanLimitsModel({
    required this.maxBusinessCards,
    required this.maxSavedCards,
    required this.maxEventGroups,
    required this.maxTeamSeats,
  });

  final int? maxBusinessCards;
  final int? maxSavedCards;
  final int? maxEventGroups;
  final int maxTeamSeats;

  factory PlanLimitsModel.fromJson(Map<String, dynamic> json) {
    return PlanLimitsModel(
      maxBusinessCards: _readNullableInt(
          json['maxBusinessCards'] ?? json['MaxBusinessCards']),
      maxSavedCards:
          _readNullableInt(json['maxSavedCards'] ?? json['MaxSavedCards']),
      maxEventGroups:
          _readNullableInt(json['maxEventGroups'] ?? json['MaxEventGroups']),
      maxTeamSeats: _readInt(
        json['maxTeamSeats'] ?? json['MaxTeamSeats'],
        fallback: 1,
      ),
    );
  }

  PlanLimits toEntity() {
    return PlanLimits(
      maxBusinessCards: maxBusinessCards,
      maxSavedCards: maxSavedCards,
      maxEventGroups: maxEventGroups,
      maxTeamSeats: maxTeamSeats,
    );
  }
}

bool _readBool(dynamic value) => ApiResponseParser.readBool(value);

int _readInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

int? _readNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
