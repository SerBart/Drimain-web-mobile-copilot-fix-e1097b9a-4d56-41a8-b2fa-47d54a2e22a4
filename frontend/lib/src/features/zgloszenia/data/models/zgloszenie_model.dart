/// Model representing a Zgloszenie (Issue)
class ZgloszenieModel {
  final int? id;
  final String tytul;
  final String opis;
  final String? typ;
  final String? status;
  final String? imie;
  final String? nazwisko;
  final String? maszyna;
  final DateTime? dataUtworzenia;
  final DateTime? dataZamkniecia;
  
  const ZgloszenieModel({
    this.id,
    required this.tytul,
    required this.opis,
    this.typ,
    this.status,
    this.imie,
    this.nazwisko,
    this.maszyna,
    this.dataUtworzenia,
    this.dataZamkniecia,
  });
  
  /// Create ZgloszenieModel from JSON
  factory ZgloszenieModel.fromJson(Map<String, dynamic> json) {
    return ZgloszenieModel(
      id: json['id'] as int?,
      tytul: json['tytul'] as String,
      opis: json['opis'] as String,
      typ: json['typ'] as String?,
      status: json['status'] as String?,
      imie: json['imie'] as String?,
      nazwisko: json['nazwisko'] as String?,
      maszyna: json['maszyna'] as String?,
      dataUtworzenia: json['dataUtworzenia'] != null 
          ? DateTime.parse(json['dataUtworzenia'] as String)
          : null,
      dataZamkniecia: json['dataZamkniecia'] != null 
          ? DateTime.parse(json['dataZamkniecia'] as String)
          : null,
    );
  }
  
  /// Convert ZgloszenieModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tytul': tytul,
      'opis': opis,
      'typ': typ,
      'status': status,
      'imie': imie,
      'nazwisko': nazwisko,
      'maszyna': maszyna,
      'dataUtworzenia': dataUtworzenia?.toIso8601String(),
      'dataZamkniecia': dataZamkniecia?.toIso8601String(),
    };
  }
  
  /// Create a copy with updated fields
  ZgloszenieModel copyWith({
    int? id,
    String? tytul,
    String? opis,
    String? typ,
    String? status,
    String? imie,
    String? nazwisko,
    String? maszyna,
    DateTime? dataUtworzenia,
    DateTime? dataZamkniecia,
  }) {
    return ZgloszenieModel(
      id: id ?? this.id,
      tytul: tytul ?? this.tytul,
      opis: opis ?? this.opis,
      typ: typ ?? this.typ,
      status: status ?? this.status,
      imie: imie ?? this.imie,
      nazwisko: nazwisko ?? this.nazwisko,
      maszyna: maszyna ?? this.maszyna,
      dataUtworzenia: dataUtworzenia ?? this.dataUtworzenia,
      dataZamkniecia: dataZamkniecia ?? this.dataZamkniecia,
    );
  }
  
  @override
  String toString() {
    return 'ZgloszenieModel(id: $id, tytul: $tytul, status: $status)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ZgloszenieModel) return false;
    return id == other.id;
  }
  
  @override
  int get hashCode => id.hashCode;
}