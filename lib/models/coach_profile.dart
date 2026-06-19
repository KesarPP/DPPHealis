import 'dart:convert';

class CoachProfile {
  final String uid;
  final String name;
  final String email;
  final String title;
  final String about;
  final List<String> specializations;
  final List<Map<String, String>> credentials;
  final String? localImagePath;

  CoachProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.title,
    required this.about,
    required this.specializations,
    required this.credentials,
    this.localImagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'title': title,
      'about': about,
      'specializations': specializations,
      'credentials': credentials.map((c) => Map<String, String>.from(c)).toList(),
      'localImagePath': localImagePath,
    };
  }

  factory CoachProfile.fromMap(Map<String, dynamic> map, {required String defaultName, required String defaultEmail}) {
    final email = map['email'] as String? ?? defaultEmail;
    final isDefaultCoach = email.toLowerCase() == 'coach@healis.org' || 
                           email.toLowerCase() == 'sarah.mitchell@healis.org' ||
                           email.toLowerCase() == 'default_coach' ||
                           email.toLowerCase() == 'kesar.parab@healis.org';

    final rawCredentials = map['credentials'] as List<dynamic>?;
    final List<Map<String, String>> parsedCredentials = [];
    if (rawCredentials != null) {
      for (var item in rawCredentials) {
        if (item is Map) {
          parsedCredentials.add({
            'title': (item['title'] as String?) ?? '',
            'subtitle': (item['subtitle'] as String?) ?? '',
            'icon': (item['icon'] as String?) ?? 'verified',
          });
        }
      }
    }

    final rawSpecs = map['specializations'] as List<dynamic>?;
    final List<String> parsedSpecs = rawSpecs != null
        ? List<String>.from(rawSpecs.map((e) => e.toString()))
        : (isDefaultCoach ? ['Nutrition', 'Behavioral Health', 'Metabolic Fitness', 'Diabetes Prevention'] : <String>[]);

    return CoachProfile(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? defaultName,
      email: email,
      title: map['title'] as String? ?? (isDefaultCoach ? 'Senior Health Coach & Nutritionist' : ''),
      about: map['about'] as String? ??
          (isDefaultCoach
              ? 'Kesar specializes in preventative health with a focus on chronic disease management. With over 15 years of clinical experience, she empowers her patients to master their metabolic health through evidence-based nutritional strategies and behavioral therapy.'
              : ''),
      specializations: parsedSpecs,
      credentials: parsedCredentials.isNotEmpty
          ? parsedCredentials
          : (isDefaultCoach
              ? [
                  {
                    'title': 'Board Certified Health Coach',
                    'subtitle': 'American Council on Exercise (ACE)',
                    'icon': 'verified',
                  },
                  {
                    'title': 'MS in Clinical Nutrition',
                    'subtitle': 'Johns Hopkins University',
                    'icon': 'school',
                  },
                  {
                    'title': 'Certified Diabetes Care Specialist',
                    'subtitle': 'ADCES Certification Board',
                    'icon': 'premium',
                  },
                ]
              : <Map<String, String>>[]),
      localImagePath: map['localImagePath'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory CoachProfile.fromJson(String source, {required String defaultName, required String defaultEmail}) =>
      CoachProfile.fromMap(json.decode(source) as Map<String, dynamic>,
          defaultName: defaultName, defaultEmail: defaultEmail);
}
