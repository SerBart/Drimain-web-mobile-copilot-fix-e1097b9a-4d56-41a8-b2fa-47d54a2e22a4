class Zgloszenie {
  final int? id;
  final String typ;
  final String imie;
  final String nazwisko;
  final String? tytul;
  final String status;
  final String? priorytet;
  final String opis;
  final DateTime? dataGodzina;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? dzialId;
  final String? dzialNazwa;
  final int? autorId;
  final String? autorUsername;
  final bool hasPhoto;

  const Zgloszenie({
    this.id,
    required this.typ,
    required this.imie,
    required this.nazwisko,
    this.tytul,
    required this.status,
    this.priorytet,
    required this.opis,
    this.dataGodzina,
    this.createdAt,
    this.updatedAt,
    this.dzialId,
    this.dzialNazwa,
    this.autorId,
    this.autorUsername,
    this.hasPhoto = false,
  });

  factory Zgloszenie.fromJson(Map<String, dynamic> json) {
    return Zgloszenie(
      id: json['id'],
      typ: json['typ'] ?? '',
      imie: json['imie'] ?? '',
      nazwisko: json['nazwisko'] ?? '',
      tytul: json['tytul'],
      status: json['status'] ?? '',
      priorytet: json['priorytet'],
      opis: json['opis'] ?? '',
      dataGodzina: json['dataGodzina'] != null 
          ? DateTime.tryParse(json['dataGodzina'])
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      dzialId: json['dzialId'],
      dzialNazwa: json['dzialNazwa'],
      autorId: json['autorId'],
      autorUsername: json['autorUsername'],
      hasPhoto: json['hasPhoto'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'typ': typ,
      'imie': imie,
      'nazwisko': nazwisko,
      if (tytul != null) 'tytul': tytul,
      'status': status,
      if (priorytet != null) 'priorytet': priorytet,
      'opis': opis,
      if (dataGodzina != null) 'dataGodzina': dataGodzina!.toIso8601String(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (dzialId != null) 'dzialId': dzialId,
      if (dzialNazwa != null) 'dzialNazwa': dzialNazwa,
      if (autorId != null) 'autorId': autorId,
      if (autorUsername != null) 'autorUsername': autorUsername,
      'hasPhoto': hasPhoto,
    };
  }

  String get fullName => '$imie $nazwisko';
  
  String get displayTitle => tytul?.isNotEmpty == true ? tytul! : 'Zgłoszenie $typ';
}

// Create request model
class ZgloszenieCreateRequest {
  final String typ;
  final String imie;
  final String nazwisko;
  final String? tytul;
  final String? priorytet;
  final String opis;
  final DateTime? dataGodzina;
  final int? dzialId;

  const ZgloszenieCreateRequest({
    required this.typ,
    required this.imie,
    required this.nazwisko,
    this.tytul,
    this.priorytet = 'NORMALNY',
    required this.opis,
    this.dataGodzina,
    this.dzialId,
  });

  Map<String, dynamic> toJson() {
    return {
      'typ': typ,
      'imie': imie,
      'nazwisko': nazwisko,
      if (tytul != null) 'tytul': tytul,
      if (priorytet != null) 'priorytet': priorytet,
      'opis': opis,
      if (dataGodzina != null) 'dataGodzina': dataGodzina!.toIso8601String(),
      if (dzialId != null) 'dzialId': dzialId,
    };
  }
}

// Update request model
class ZgloszenieUpdateRequest {
  final String? typ;
  final String? imie;
  final String? nazwisko;
  final String? tytul;
  final String? status;
  final String? priorytet;
  final String? opis;
  final DateTime? dataGodzina;
  final int? dzialId;

  const ZgloszenieUpdateRequest({
    this.typ,
    this.imie,
    this.nazwisko,
    this.tytul,
    this.status,
    this.priorytet,
    this.opis,
    this.dataGodzina,
    this.dzialId,
  });

  Map<String, dynamic> toJson() {
    return {
      if (typ != null) 'typ': typ,
      if (imie != null) 'imie': imie,
      if (nazwisko != null) 'nazwisko': nazwisko,
      if (tytul != null) 'tytul': tytul,
      if (status != null) 'status': status,
      if (priorytet != null) 'priorytet': priorytet,
      if (opis != null) 'opis': opis,
      if (dataGodzina != null) 'dataGodzina': dataGodzina!.toIso8601String(),
      if (dzialId != null) 'dzialId': dzialId,
    };
  }
}