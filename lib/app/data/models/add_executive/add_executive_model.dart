// lib/app/data/models/add_executive/add_executive_model.dart
import 'dart:io';

class AddExecutiveModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final DateTime dateOfBirth;
  final String address;
  final File? profileImage;
  final DateTime joiningDate;
  final String role;

  AddExecutiveModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.dateOfBirth,
    required this.address,
    this.profileImage,
    required this.joiningDate,
    required this.role,
  });

  AddExecutiveModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? mobile,
    DateTime? dateOfBirth,
    String? address,
    File? profileImage,
    DateTime? joiningDate,
    String? role,
  }) {
    return AddExecutiveModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      joiningDate: joiningDate ?? this.joiningDate,
      role: role ?? this.role,
    );
  }
}
