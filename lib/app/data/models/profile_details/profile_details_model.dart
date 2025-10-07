class ProfileDetailsModel {
  final String name;
  final String phoneNumber;
  final String emailId;
  final String address;
  final String designation;
  final String joiningDate;
  final String dob;

  ProfileDetailsModel({
    required this.name,
    required this.phoneNumber,
    required this.emailId,
    required this.address,
    required this.designation,
    required this.joiningDate,
    required this.dob,
  });

  factory ProfileDetailsModel.fromJson(Map<String, dynamic> json) {
    return ProfileDetailsModel(
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      emailId: json['email_id'] ?? '',
      address: json['address'] ?? '',
      designation: json['designation'] ?? '',
      joiningDate: json['joining_date'] ?? '',
      dob: json['dob'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone_number': phoneNumber,
      'email_id': emailId,
      'address': address,
      'designation': designation,
      'joining_date': joiningDate,
      'dob': dob,
    };
  }
}
