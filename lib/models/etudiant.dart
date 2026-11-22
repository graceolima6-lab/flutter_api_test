class Etudiant {
  final int? id;
  final String nom;
  final String postnom;
  final String prenom;
  final String adresse;
  final String telephone;

  Etudiant({
    this.id,
    required this.nom,
    required this.postnom,
    required this.prenom,
    required this.adresse,
    required this.telephone,
  });

  factory Etudiant.fromJson(Map<String, dynamic> json) {
    return Etudiant(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      nom: json['nom']?.toString() ?? '',
      postnom: json['postnom']?.toString() ?? '',
      prenom: json['prenom']?.toString() ?? '',
      adresse: json['adresse']?.toString() ?? '',
      telephone: json['telephone']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'postnom': postnom,
      'prenom': prenom,
      'adresse': adresse,
      'telephone': telephone,
    };
  }
}