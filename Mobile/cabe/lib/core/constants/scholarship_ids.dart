/// Konstanta ID untuk setiap beasiswa, sinkron dengan koleksi `scholarship_progress` di Firestore.
class ScholarshipIds {
  ScholarshipIds._();

  static const buk  = '10000000-0000-4000-a000-000000000001'; // Beasiswa Unggulan Kemendikbud
  static const bapk = '10000000-0000-4000-a000-000000000002'; // Beasiswa Atlet Berprestasi KONI
  static const bsnd = '10000000-0000-4000-a000-000000000003'; // Beasiswa Seni Budaya Nusantara
  static const ppt  = '10000000-0000-4000-a000-000000000004'; // Paragon for Future Leaders
  static const lpdp = '10000000-0000-4000-a000-000000000005'; // LPDP Beasiswa Reguler
  static const ai   = '10000000-0000-4000-a000-000000000006'; // Beasiswa Astra 1st
  static const tf   = '10000000-0000-4000-a000-000000000007'; // TELADAN - Tanoto Foundation

  /// Map acronym → UUID
  static const Map<String, String> acronymToId = {
    'BUK': buk,
    'BAPK': bapk,
    'BSND': bsnd,
    'PPT': ppt,
    'LPDP': lpdp,
    'AI': ai,
    'TF': tf,
  };

  /// Map UUID → acronym
  static const Map<String, String> idToAcronym = {
    buk: 'BUK',
    bapk: 'BAPK',
    bsnd: 'BSND',
    ppt: 'PPT',
    lpdp: 'LPDP',
    ai: 'AI',
    tf: 'TF',
  };

  /// Mendapatkan acronym dari scholarship ID
  static String? getAcronym(String id) => idToAcronym[id];

  /// Mendapatkan UUID dari acronym
  static String? getId(String acronym) => acronymToId[acronym];
}
