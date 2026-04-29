import 'package:flutter/material.dart';

class DetailBeasiswaPage extends StatelessWidget {
  const DetailBeasiswaPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color navyColor = Color(0xFF001F3F);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: const BoxDecoration(
                color: navyColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Icon(Icons.bookmark_outline, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Beasiswa Unggulan Kemendikbud",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Kemendikbud RI",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        color: Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "23% Kecocokan",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "21 Hari Lagi !",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Daftar Sekarang",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Tentang Beasiswa"),
                  const Text(
                    "Beasiswa Unggulan merupakan program beasiswa yang diselenggarakan oleh Kementerian Pendidikan dan Kebudayaan RI untuk siswa berprestasi. Program ini mencakup biaya pendidikan, biaya hidup, dan tunjangan buku selama masa studi.",
                    style: TextStyle(color: Colors.grey, height: 1.5),
                  ),

                  const Divider(height: 40),
                  _buildSectionTitle("Persyaratan"),
                  _buildListPoint("Nilai rapor rata - rata minimal 8.5"),
                  _buildListPoint("Aktif dalam organisasi sekolah"),
                  _buildListPoint(
                    "Memiliki prestasi akademik tingkat kabupaten / kota",
                  ),
                  _buildListPoint("Surat rekomendasi dari kepala sekolah"),

                  const Divider(height: 40),
                  _buildSectionTitle("Kriteria Kelayakan"),
                  _buildCriteriaRow("Min. Nilai Rapor", "85"),
                  _buildCriteriaRow("Kelas", "11, 12"),
                  _buildCriteriaRow("Jurusan", "IPA, IPS, Bahasa"),

                  const Divider(height: 40),
                  _buildSectionTitle("Dokumen Diperlukan"),
                  _buildDocumentPoint("Fotokopi rapor semester terakhir"),
                  _buildDocumentPoint("Surat rekomendasi kepala sekolah"),
                  _buildDocumentPoint("Esai motivasi (500 kata)"),
                  _buildDocumentPoint("Fotokopi KTP / Kartu Pelajar"),
                  _buildDocumentPoint("Pas foto 3x4"),
                  _buildDocumentPoint("Sertifikat prestasi"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF001F3F),
        ),
      ),
    );
  }

  Widget _buildListPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCriteriaRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1F8), // Light Blue-Grey background
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
