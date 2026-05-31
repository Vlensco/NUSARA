import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/core/services/ai_service.dart';
import 'package:cabe/features/profile_setup/models/profile_setup_data.dart';
import 'package:cabe/features/profile_setup/controllers/welcome_controller.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ReadinessScoreScreen extends StatefulWidget {
  final String userName;
  final ProfileSetupData profileData;

  const ReadinessScoreScreen({
    super.key,
    required this.userName,
    required this.profileData,
  });

  @override
  State<ReadinessScoreScreen> createState() => _ReadinessScoreScreenState();
}

class _ReadinessScoreScreenState extends State<ReadinessScoreScreen>
    with TickerProviderStateMixin {
  ReadinessResult? _result;
  bool _isLoading = true;
  late AnimationController _animController;
  late Animation<double> _scoreAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scoreAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    // Pulse animation for loading icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Dot animation for "Sedang menganalisis..."
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _fetchReadinessScore();
  }

  @override
  void dispose() {
    _animController.dispose();
    _pulseController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  Future<void> _fetchReadinessScore() async {
    final pd = widget.profileData;
    final nilai = double.tryParse(pd.nilaiRataRata.replaceAll(',', '.')) ?? 0;

    final result = await AiService.getReadinessScore(
      nilaiRapor: nilai,
      tipeNilai: pd.tipeNilai.isNotEmpty ? pd.tipeNilai : 'rapor',
      penghasilanOrtu: pd.penghasilanOrtu.isNotEmpty ? pd.penghasilanOrtu : '> 5 Juta',
      bantuanSosial: pd.bantuanSosial.isNotEmpty ? pd.bantuanSosial : 'Tidak ada',
      tanggungan: pd.tanggungan.isNotEmpty ? pd.tanggungan : 'Tidak ada',
      pekerjaanOrtu: pd.pekerjaanOrtu.isNotEmpty ? pd.pekerjaanOrtu : 'Tetap',
      levelPrestasi: pd.levelPrestasi.isNotEmpty ? pd.levelPrestasi : 'Tidak ada',
      jumlahPrestasi: pd.jumlahPrestasi.isNotEmpty ? pd.jumlahPrestasi : 'Tidak Ada',
      organisasi: pd.organisasi.isNotEmpty ? pd.organisasi : 'Tidak ada',
      aktivitasTambahan: pd.aktivitasTambahan.isNotEmpty ? pd.aktivitasTambahan : 'Tidak ada',
      dokumenPendukung: pd.dokumenPendukung,
      kejelasanTujuan: pd.kejelasanTujuan.isNotEmpty ? pd.kejelasanTujuan : 'Belum yakin',
      tujuanKarir: pd.tujuanKarir.isNotEmpty ? pd.tujuanKarir : 'Belum ada',
      keterkaitan: pd.keterkaitan.isNotEmpty ? pd.keterkaitan : 'Belum sesuai / belum tahu',
      userName: widget.userName,
    );

    if (!mounted) return;

    // ─── Save readiness result to Firestore ───
    _saveReadinessToFirestore(result);

    setState(() {
      _result = result;
      _isLoading = false;
      _scoreAnimation = Tween<double>(begin: 0, end: result.totalScore).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
      );
    });
    _animController.forward();
  }

  /// Persist the readiness score + tips to the user's Firestore document
  Future<void> _saveReadinessToFirestore(ReadinessResult result) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'readiness_total': result.totalScore,
        'readiness_akademik': result.skorAkademik,
        'readiness_finansial': result.skorFinansial,
        'readiness_non_akademik': result.skorNonAkademik,
        'readiness_sertifikat': result.skorSertifikat,
        'readiness_motivasi': result.skorMotivasi,
        'readiness_label': result.label,
        'readiness_tips': result.tips,
        'readiness_updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to save readiness to Firestore: $e');
    }
  }

  Color _scoreColor(double score) {
    if (score >= 80) return AppColors.successText;
    if (score >= 60) return const Color(0xFFFF6200);
    if (score >= 40) return AppColors.warningText;
    return AppColors.dangerText;
  }

  Color _scoreBgColor(double score) {
    if (score >= 80) return AppColors.successBg;
    if (score >= 60) return const Color(0xFFFEF1D2);
    if (score >= 40) return AppColors.warningBg;
    return AppColors.dangerBg;
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildWelcomingAnalysis();
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: _buildContent(),
      ),
    );
  }

  // ─── Welcoming Analysis Screen (Loading) ───
  Widget _buildWelcomingAnalysis() {
    return Scaffold(
      backgroundColor: AppColors.blue900,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Logo App ───
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/logo/logo_cabe_0.png',
                  width: 140,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 36),

              // ─── Baris 1: Welcome [Nama Lengkap]! ───
              Text(
                'Welcome ${widget.userName}!',
                style: AppTextStyles.h2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // ─── Baris 2: Sedang menganalisis profilmu... ───
              AnimatedBuilder(
                animation: _dotController,
                builder: (context, _) {
                  final dots = '.' * ((_dotController.value * 3).floor() + 1);
                  return Text(
                    'Sedang menganalisis profilmu$dots',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: 8),

              // ─── Baris 3: Micro-copy ───
              Text(
                'Tunggu beberapa detik ya, kami sedang\nmeracik beasiswa yang pas buatmu.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white54,
                  fontSize: 12,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // ─── Circular loading spinner ───
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final result = _result!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          Text(
            'Skor Kesiapan Beasiswa',
            style: AppTextStyles.h2.copyWith(color: AppColors.blue900),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Hai ${widget.userName}! Ini hasil analisis profilmu.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // ─── Circular Score ───
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, _) {
              final animatedScore = _scoreAnimation.value;
              return Column(
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CustomPaint(
                      painter: _ScoreRingPainter(
                        score: animatedScore,
                        color: _scoreColor(result.totalScore),
                        bgColor: _scoreBgColor(result.totalScore),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              animatedScore.toStringAsFixed(0),
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: _scoreColor(result.totalScore),
                              ),
                            ),
                            Text(
                              'dari 100',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray400),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Label Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: _scoreBgColor(result.totalScore),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              result.label,
              style: AppTextStyles.labelLarge.copyWith(
                color: _scoreColor(result.totalScore),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ─── Breakdown Per Aspek ───
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Skor per Aspek',
                  style: AppTextStyles.h4.copyWith(color: AppColors.blue900),
                ),
                const SizedBox(height: 16),
                _buildScoreBar('Akademik', result.skorAkademik, 40, const Color(0xFF002147)),
                _buildScoreBar('Finansial', result.skorFinansial, 25, const Color(0xFF002147)),
                _buildScoreBar('Non-Akademik', result.skorNonAkademik, 25, const Color(0xFF002147)),
                _buildScoreBar('Sertifikat', result.skorSertifikat, 5, const Color(0xFF002147)),
                _buildScoreBar('Motivasi', result.skorMotivasi, 5, const Color(0xFF002147)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── Tips Peningkatan dari AI ───
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.blue100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.blue200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.blue500.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        LucideIcons.lightbulb,
                        size: 20,
                        color: AppColors.blue600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tips Peningkatan',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.blue900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFormattedTips(result.tips),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ─── Button Lanjut ke Home ───
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final welcomeCtrl = WelcomeController();
                welcomeCtrl.goToHome(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue900,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Mulai Jelajahi Beasiswa',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(LucideIcons.arrowRight, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, double score, double maxScore, Color color) {
    final percentage = maxScore > 0 ? (score / maxScore).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${score.toStringAsFixed(1)} / ${maxScore.toStringAsFixed(0)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: const Color(0xFFE6EBF0),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  /// Build formatted tips with proper visual hierarchy
  Widget _buildFormattedTips(String tipsRaw) {
    // Parse the structured format into rich text spans
    final lines = tipsRaw.split('\n');
    final List<Widget> children = [];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        children.add(const SizedBox(height: 8));
        continue;
      }

      // Section headers: "Ringkasan Evaluasi:" or "Langkah Peningkatan:"
      if (trimmed == 'Ringkasan Evaluasi:' || trimmed == 'Langkah Peningkatan:') {
        children.add(Padding(
          padding: EdgeInsets.only(top: children.isEmpty ? 0 : 8, bottom: 4),
          child: Text(
            trimmed,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.blue900,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ));
        continue;
      }

      // Numbered items: "1. **Aspek**: Saran tindakan."
      final numberedMatch = RegExp(r'^(\d+)\.\s*\*\*(.+?)\*\*:\s*(.+)$').firstMatch(trimmed);
      if (numberedMatch != null) {
        final number = numberedMatch.group(1)!;
        final aspect = numberedMatch.group(2)!;
        final saran = numberedMatch.group(3)!;

        children.add(Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$number. ',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.blue800,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$aspect: ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.blue900,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                      TextSpan(
                        text: saran,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.blue800,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
        continue;
      }

      // Regular text line (e.g., ringkasan content)
      children.add(Text(
        trimmed,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.blue800,
          height: 1.6,
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

// ─── Custom Painter untuk Ring Score ───
class _ScoreRingPainter extends CustomPainter {
  final double score;
  final Color color;
  final Color bgColor;

  _ScoreRingPainter({
    required this.score,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 12;
    final strokeWidth = 14.0;

    // Background ring
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Score ring
    final scorePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return oldDelegate.score != score;
  }
}
