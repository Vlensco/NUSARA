import 'package:easy_localization/easy_localization.dart';

class TranslationHelper {
  static String translateTitle(String rawTitle, String langCode) {
    if (langCode != 'en') return rawTitle;
    switch (rawTitle.trim()) {
      case 'Beasiswa Unggulan Kemendikbud': return 'Kemendikbud Outstanding Scholarship';
      case 'Beasiswa Atlet Berprestasi KONI': return 'KONI Outstanding Athlete Scholarship';
      case 'Beasiswa Seni Budaya Nusantara': return 'Nusantara Arts and Culture Scholarship';
      case 'Paragon for Future Leaders': return 'Paragon for Future Leaders';
      case 'LPDP Beasiswa Reguler': return 'LPDP Regular Scholarship';
      case 'Beasiswa Astra 1st': return 'Astra 1st Scholarship';
      case 'TELADAN - Tanoto Foundation': return 'TELADAN - Tanoto Foundation';
      default: return rawTitle;
    }
  }

  static String translateSection(String rawSection, String langCode) {
    if (langCode != 'en') return rawSection;
    switch (rawSection.trim()) {
      case 'Dokumen': return 'Documents';
      case 'Esai': return 'Essays';
      case 'Video / Foto Dokumentasi': return 'Video / Photo Documentation';
      default: return rawSection;
    }
  }

  static String translateDocument(String rawDoc, String langCode) {
    if (langCode != 'en') return rawDoc;
    switch (rawDoc.trim()) {
      case 'Fotokopi Rapor / Transkrip Nilai': return 'Photocopy of Report Card / Transcript of Grades';
      case 'Sertifikat Prestasi / Medali Kejuaraan': return 'Achievement Certificate / Championship Medal';
      case 'Surat rekomendasi umum / dosen': return 'General / lecturer recommendation letter';
      case 'CV': return 'CV';
      case 'Fotokopi rapor semester terakhir': return 'Photocopy of the latest semester report card';
      case 'Surat rekomendasi kepala sekolah': return 'Recommendation letter from the principal';
      case 'Esai motivasi (500 kata)': return 'Motivation essay (500 words)';
      case 'Fotokopi KTP / Kartu Pelajar': return 'Photocopy of ID Card / Student Card';
      case 'Pas foto 3x4': return '3x4 photo';
      case 'Sertifikat prestasi': return 'Achievement certificate';
      case 'Sertifikat / medali kejuaraan': return 'Championship certificate / medal';
      case 'Surat rekomendasi KONI daerah': return 'Recommendation letter from regional KONI';
      case 'Fotokopi rapor': return 'Photocopy of report card';
      case 'Foto aksi olahraga': return 'Sports action photo';
      case 'Riwayat prestasi olahraga': return 'Sports achievement history';
      case 'Portofolio karya seni': return 'Art portfolio';
      case 'Video penampilan seni (5 menit)': return 'Art performance video (5 minutes)';
      case 'Sertifikat prestasi seni': return 'Art achievement certificate';
      case 'Esai tentang visi pelestarian budaya': return 'Essay on cultural preservation vision';
      case 'Proposal ide bisnis / proyek': return 'Business idea / project proposal';
      case 'Esai tentang semangat inovasi': return 'Essay on the spirit of innovation';
      case 'Dokumentasi proyek / usaha (jika ada)': return 'Project / business documentation (if any)';
      case 'Surat rekomendasi': return 'Recommendation letter';
      case 'Transkrip nilai / rapor': return 'Transcript of grades / report card';
      case 'Surat keterangan sehat': return 'Healthy certificate';
      case 'Esai rencana studi': return 'Study plan essay';
      case 'CV / daftar riwayat hidup': return 'CV / curriculum vitae';
      case 'Fotokopi KTP': return 'Photocopy of ID Card (KTP)';
      case 'SKCK': return 'Police Record Certificate (SKCK)';
      case 'Esai tentang minat di bidang teknologi': return 'Essay about interest in technology';
      case 'Fotokopi kartu pelajar': return 'Photocopy of student card';
      case 'Formulir pendaftaran': return 'Registration form';
      case 'Fotokopi rapor 2 semester terakhir': return 'Photocopy of report card for the last 2 semesters';
      case 'Esai kepemimpinan dan kontribusi sosial': return 'Essay on leadership and social contribution';
      case 'Video perkenalan (3 menit)': return 'Introduction video (3 minutes)';
      default: return rawDoc;
    }
  }

  static String translateRequirement(String rawReq, String langCode) {
    if (langCode != 'en') return rawReq;
    switch (rawReq.trim()) {
      case 'Nilai rapor rata - rata minimal 8.5': return 'Minimum average report score of 8.5';
      case 'Aktif dalam organisasi sekolah': return 'Active in school organizations';
      case 'Memiliki prestasi akademik tingkat kabupaten / kota': return 'Have academic achievements at the district/city level';
      case 'Surat rekomendasi dari kepala sekolah': return 'Recommendation letter from the school principal';
      case 'Atlet berprestasi tingkat provinsi / nasional': return 'Provincial/national level high-achieving athlete';
      case 'Masih aktif berlatih dan bertanding': return 'Still actively training and competing';
      case 'Nilai rapor rata - rata minimal 7.0': return 'Minimum average report score of 7.0';
      case 'Rekomendasi dari pengurus cabang olahraga': return 'Recommendation from sports branch management';
      case 'Memiliki prestasi di bidang seni / budaya': return 'Have achievements in arts / culture';
      case 'Aktif dalam kegiatan seni di sekolah / komunitas': return 'Active in art activities at school / community';
      case 'Menguasai minimal satu bidang seni tradisional': return 'Master at least one traditional art field';
      case 'Memiliki minat kewirausahaan': return 'Have entrepreneurship interest';
      case 'Nilai rapor rata - rata minimal 7.5': return 'Minimum average report score of 7.5';
      case 'Pernah membuat proyek / usaha kecil (diutamakan)': return 'Has made a project / small business (preferred)';
      case 'Bersedia mengikuti program mentoring': return 'Willing to follow the mentoring program';
      case 'IPK minimal 3.0 atau nilai rapor rata - rata 8.0': return 'Minimum GPA of 3.0 or average report score of 8.0';
      case 'Usia maksimal 25 tahun': return 'Maximum age of 25 years';
      case 'Sehat jasmani dan rohani': return 'Physically and mentally healthy';
      case 'Tidak sedang menerima beasiswa lain': return 'Not currently receiving another scholarship';
      case 'Siswa SMK jurusan teknik / otomotif': return 'Vocational school students majoring in engineering / automotive';
      case 'Nilai rapor rata - rata minimal 80': return 'Minimum average report card score of 80';
      case 'Tertarik di bidang otomotif dan teknologi': return 'Interested in automotive and technology';
      case 'Bersedia mengikuti program magang': return 'Willing to join the internship program';
      case 'Aktif dalam kegiatan kepemimpinan': return 'Active in leadership activities';
      case 'Memiliki rencana kontribusi sosial': return 'Has a social contribution plan';
      case 'Bersedia mengikuti program pengembangan': return 'Willing to join the development program';
      default: return rawReq;
    }
  }

  static String translateDescription(String rawDesc, String langCode) {
    if (langCode != 'en') return rawDesc;
    if (rawDesc.contains('Beasiswa Unggulan merupakan program beasiswa')) {
      return 'The Outstanding Scholarship is a scholarship program organized by the Indonesian Ministry of Education and Culture for high-achieving students. This program covers tuition fees, living allowances, and book allowances during the study period.';
    }
    if (rawDesc.contains('Program beasiswa khusus untuk atlet pelajar')) {
      return 'A special scholarship program for high-achieving student athletes who have represented their region or nation in official sports competitions. Covers educational and training costs.';
    }
    if (rawDesc.contains('Beasiswa untuk siswa yang memiliki bakat')) {
      return 'Scholarship for students who have talent and achievements in the field of Indonesian arts and culture. Supports the preservation and development of archipelago arts and culture through education.';
    }
    if (rawDesc.contains('Beasiswa dari Paragon Technology')) {
      return 'Scholarship from Paragon Technology and Innovation for high school/vocational school students who have a spirit of innovation and entrepreneurship. This program also includes entrepreneurship training and mentoring.';
    }
    if (rawDesc.contains('Lembaga Pengelola Dana Pendidikan')) {
      return 'The Education Fund Management Institution (LPDP) offers regular scholarships for the nation\'s best sons and daughters to continue their education to a higher level at leading universities.';
    }
    if (rawDesc.contains('Program beasiswa dari PT Astra')) {
      return 'Scholarship program from PT Astra International Tbk for high-achieving vocational school students interested in automotive, engineering, and manufacturing. Includes internship opportunities at Astra companies.';
    }
    if (rawDesc.contains('Program TELADAN (Transformasi Edukasi')) {
      return 'The TELADAN program (Education Transformation for Producing Future Leaders) from Tanoto Foundation provides financial support and leadership development for high-achieving students.';
    }
    return rawDesc;
  }
}
