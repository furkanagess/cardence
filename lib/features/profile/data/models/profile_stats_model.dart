import '../../domain/entities/profile_stats.dart';

class ProfileStatsModel {
  const ProfileStatsModel({
    required this.totalWalletSaveCount,
    required this.eventGroupCount,
  });

  final int totalWalletSaveCount;
  final int eventGroupCount;

  ProfileStats toEntity() => ProfileStats(
        totalWalletSaveCount: totalWalletSaveCount,
        eventGroupCount: eventGroupCount,
      );

  factory ProfileStatsModel.fromJson(Map<String, dynamic> json) {
    int readInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return ProfileStatsModel(
      totalWalletSaveCount: readInt(
        json['totalWalletSaveCount'] ?? json['TotalWalletSaveCount'],
      ),
      eventGroupCount: readInt(
        json['eventGroupCount'] ?? json['EventGroupCount'],
      ),
    );
  }
}
