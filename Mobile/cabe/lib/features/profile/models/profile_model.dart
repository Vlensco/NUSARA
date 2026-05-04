class ProfileModel {
  final String name;
  final String school;
  final String grade;
  final String major;
  final int score;
  final double progress;
  final String status;

  final int profileCompletionScore;
  final int profileCompletionMax;
  final double profileCompletionProgress;

  final int documentReadinessScore;
  final int documentReadinessMax;
  final double documentReadinessProgress;

  final int academicStrengthScore;
  final int academicStrengthMax;
  final double academicStrengthProgress;

  final int activityAchievementScore;
  final int activityAchievementMax;
  final double activityAchievementProgress;

  final int savedCount;
  final int reviewedCount;
  final int acceptedCount;
  final List<String> interests;
  final List<String> achievements;
  final int reportScore;
  final int toeicScore;

  ProfileModel({
    required this.name,
    required this.school,
    required this.grade,
    required this.major,
    required this.score,
    required this.progress,
    required this.status,
    required this.profileCompletionScore,
    required this.profileCompletionMax,
    required this.profileCompletionProgress,
    required this.documentReadinessScore,
    required this.documentReadinessMax,
    required this.documentReadinessProgress,
    required this.academicStrengthScore,
    required this.academicStrengthMax,
    required this.academicStrengthProgress,
    required this.activityAchievementScore,
    required this.activityAchievementMax,
    required this.activityAchievementProgress,
    required this.savedCount,
    required this.reviewedCount,
    required this.acceptedCount,
    required this.interests,
    required this.achievements,
    required this.reportScore,
    required this.toeicScore,
  });
}
