class ProfileModel {
  final String name;
  final String school;
  final String grade;
  final String major;
  final int score;
  final double progress;
  final String status;
  final String tips;

  final double academicScore;
  final int academicMax;
  final double academicProgress;

  final double financialScore;
  final int financialMax;
  final double financialProgress;

  final double nonAcademicScore;
  final int nonAcademicMax;
  final double nonAcademicProgress;

  final double certRecScore;
  final int certRecMax;
  final double certRecProgress;

  final double motivationScore;
  final int motivationMax;
  final double motivationProgress;

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
    required this.tips,
    required this.academicScore,
    required this.academicMax,
    required this.academicProgress,
    required this.financialScore,
    required this.financialMax,
    required this.financialProgress,
    required this.nonAcademicScore,
    required this.nonAcademicMax,
    required this.nonAcademicProgress,
    required this.certRecScore,
    required this.certRecMax,
    required this.certRecProgress,
    required this.motivationScore,
    required this.motivationMax,
    required this.motivationProgress,
    required this.savedCount,
    required this.reviewedCount,
    required this.acceptedCount,
    required this.interests,
    required this.achievements,
    required this.reportScore,
    required this.toeicScore,
  });
}
