enum NotifikasiType { ditinjau, diterima, ditolak, deadline }

class NotifikasiModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final NotifikasiType type;
  final int? daysLeft; // Hanya untuk tipe deadline

  NotifikasiModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
    this.type = NotifikasiType.ditinjau,
    this.daysLeft,
  });

  NotifikasiModel copyWith({
    String? id,
    String? title,
    String? message,
    String? time,
    bool? isRead,
    NotifikasiType? type,
    int? daysLeft,
  }) {
    return NotifikasiModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      daysLeft: daysLeft ?? this.daysLeft,
    );
  }
}
