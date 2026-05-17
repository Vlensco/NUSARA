import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_model.dart';

class ProfileController extends Notifier<ProfileModel> {
  @override
  ProfileModel build() {
    return ProfileModel(
      name: '',
      school: '',
      grade: '',
      major: '',
      score: 0,
      progress: 0.0,
      status: 'Belum Dinilai',
      profileCompletionScore: 0,
      profileCompletionMax: 25,
      profileCompletionProgress: 0.0,
      documentReadinessScore: 0,
      documentReadinessMax: 25,
      documentReadinessProgress: 0.0,
      academicStrengthScore: 0,
      academicStrengthMax: 25,
      academicStrengthProgress: 0.0,
      activityAchievementScore: 0,
      activityAchievementMax: 25,
      activityAchievementProgress: 0.0,
      savedCount: 0,
      reviewedCount: 0,
      acceptedCount: 0,
      interests: [],
      achievements: [],
      reportScore: 0,
      toeicScore: 0,
    );
  }
}

final profileControllerProvider = NotifierProvider<ProfileController, ProfileModel>(() {
  return ProfileController();
});
