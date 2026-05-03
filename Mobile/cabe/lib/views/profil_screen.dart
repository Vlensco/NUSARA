import 'package:flutter/material.dart';
import 'detail_beasiswa_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER SECTION ---
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DetailBeasiswaPage(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 60,
                  left: 20,
                  right: 20,
                  bottom: 40,
                ),
                decoration: const BoxDecoration(color: Color(0xFF002147)),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Color(0xFF2C4A70),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Patrick Star',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'SMA Kepulauan Riau',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildBadge('Kelas 11'),
                            const SizedBox(width: 8),
                            _buildBadge('IPA'),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white54,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),

            // --- SCORE CARD SECTION ---
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Skor Kesiapan Beasiswa",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        const SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: 0.48,
                            strokeWidth: 12,
                            backgroundColor: Color(0xFFEEEEEE),
                            color: Colors.orange,
                          ),
                        ),
                        Column(
                          children: const [
                            Text(
                              "48",
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            Text(
                              "dari 100",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Cukup Siap",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildProgressRow(
                      Icons.person_outline,
                      "Kelengkapan Profil",
                      "0 / 25",
                      0.0,
                    ),
                    _buildProgressRow(
                      Icons.description_outlined,
                      "Kesiapan Dokumen",
                      "5 / 25",
                      0.2,
                    ),
                    _buildProgressRow(
                      Icons.school_outlined,
                      "Kekuatan Akademik",
                      "25 / 25",
                      1.0,
                    ),
                    _buildProgressRow(
                      Icons.star_outline,
                      "Aktivitas & Prestasi",
                      "18 / 25",
                      0.72,
                    ),
                  ],
                ),
              ),
            ),

            // --- TIPS SECTION ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.brown),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Tips Peningkatan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                        Text(
                          "Simpan beasiswa dan mulai centang dokumen yang sudah kamu siapkan",
                          style: TextStyle(fontSize: 11, color: Colors.brown),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Statistik",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2C4A70),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }

  Widget _buildProgressRow(
    IconData icon,
    String title,
    String score,
    double progress,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 12)),
              ),
              Text(
                score,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            color: const Color(0xFF002147),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}
