// lib/models/doctor_profile.dart
class DoctorProfile {
  String fullName;
  String phone;
  String email;
  String gender;
  String city;
  String primarySpecialization;
  List<String> secondarySpecialization;
  int experienceYears;
  String nctRegistrationNo;
  String otherAccreditation;
  String profileImageBase64;
  List<Clinic> clinics;
  VideoConsultation videoConsultation;
  List<EducationRecord> educationRecords;
  List<ExperienceRecord> experienceRecords;
  List<String> services;
  List<String> conditionsTreated;
  bool agreement;
  String representativeNames;

  DoctorProfile({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.gender,
    required this.city,
    required this.primarySpecialization,
    required this.secondarySpecialization,
    required this.experienceYears,
    required this.nctRegistrationNo,
    required this.otherAccreditation,
    required this.profileImageBase64,
    required this.clinics,
    required this.videoConsultation,
    required this.educationRecords,
    required this.experienceRecords,
    required this.services,
    required this.conditionsTreated,
    required this.agreement,
    required this.representativeNames,
  });

  Map<String, dynamic> toJson() => {
    "full_name": fullName,
    "phone": phone,
    "email": email,
    "gender": gender,
    "city": city,
    "primary_specialization": primarySpecialization,
    "secondary_specialization": secondarySpecialization,
    "experience_years": experienceYears,
    "nct_registration_no": nctRegistrationNo,
    "other_accreditation": otherAccreditation,
    "profile_image": profileImageBase64,
    "clinics": clinics.map((e) => e.toJson()).toList(),
    "video_consultation": videoConsultation.toJson(),
    "education_records": educationRecords.map((e) => e.toJson()).toList(),
    "experience_records": experienceRecords.map((e) => e.toJson()).toList(),
    "services": services,
    "conditions_treated": conditionsTreated,
    "agreement": agreement,
    "representative_names": representativeNames,
  };
}

class Clinic {
  String name, address, phone, assistantCell, region, timings, days;
  int practicingSince, fees;

  Clinic({
    required this.name,
    required this.address,
    required this.phone,
    required this.assistantCell,
    required this.practicingSince,
    required this.timings,
    required this.days,
    required this.fees,
    required this.region,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "address": address,
    "phone": phone,
    "assistant_cell": assistantCell,
    "practicing_since": practicingSince,
    "timings": timings,
    "days": days,
    "fees": fees,
    "region": region,
  };
}

class VideoConsultation {
  bool isAvailable;
  String timings, days;
  int durationMinutes, fees;

  VideoConsultation({
    required this.isAvailable,
    required this.timings,
    required this.days,
    required this.durationMinutes,
    required this.fees,
  });

  Map<String, dynamic> toJson() => {
    "is_available": isAvailable,
    "timings": timings,
    "days": days,
    "duration_minutes": durationMinutes,
    "fees": fees,
  };
}

class EducationRecord {
  String degree, institute, country;
  int startYear, endYear;

  EducationRecord({
    required this.degree,
    required this.institute,
    required this.country,
    required this.startYear,
    required this.endYear,
  });

  Map<String, dynamic> toJson() => {
    "degree": degree,
    "institute": institute,
    "country": country,
    "start_year": startYear,
    "end_year": endYear,
  };
}

class ExperienceRecord {
  String position, clinicOrHospital, country;
  int startYear, endYear;

  ExperienceRecord({
    required this.position,
    required this.clinicOrHospital,
    required this.country,
    required this.startYear,
    required this.endYear,
  });

  Map<String, dynamic> toJson() => {
    "position": position,
    "clinic_or_hospital": clinicOrHospital,
    "country": country,
    "start_year": startYear,
    "end_year": endYear,
  };
}
