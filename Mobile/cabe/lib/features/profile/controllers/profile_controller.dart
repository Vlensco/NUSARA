import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_model.dart';

class ProfileController extends Notifier<ProfileModel> {
  @override
  ProfileModel build() {
    return ProfileModel(
      name: 'Patrick Star',
      school: 'SMA Kepulauan Riau',
      grade: 'Kelas 11',
      major: 'IPA',
      score: 48,
      progress: 0.48,
      status: 'Cukup Siap',
      profileCompletionScore: 0,
      profileCompletionMax: 25,
      profileCompletionProgress: 0.0,
      documentReadinessScore: 5,
      documentReadinessMax: 25,
      documentReadinessProgress: 0.2,
      academicStrengthScore: 25,
      academicStrengthMax: 25,
      academicStrengthProgress: 1.0,
      activityAchievementScore: 18,
      activityAchievementMax: 25,
      activityAchievementProgress: 0.72,
      savedCount: 6,
      reviewedCount: 1,
      acceptedCount: 1,
      interests: [
        'Matematika',
        'Sains & Teknologi',
        'Seni',
        'Kewirausahaan'
      ],
      achievements: [
        'Juara 3 Lomba Fotografi Jurnalistik tingkat nasional',
        'Juara 2 OSN Kimia tingkat kabupaten'
      ],
      reportScore: 87,
      toeicScore: 785,
    );
  }
}

final profileControllerProvider = NotifierProvider<ProfileController, ProfileModel>(() {
  return ProfileController();
});
