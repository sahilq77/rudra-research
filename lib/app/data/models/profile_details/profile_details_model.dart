class ProfileDetailsModel {
  final String image;
  final String name;
  final String phoneNumber;
  final String emailId;
  final String address;
  final String designation;
  final String joiningDate;
  final String dob;

  ProfileDetailsModel({
    required this.image,
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
      image: json['image'] ?? '',
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
      'image': image,
      'name': name,
      'phone_number': phoneNumber,
      'email_id': emailId,
      'address': address,
      'designation': designation,
      'joining_date': joiningDate,
      'dob': dob,
    };
  }

  ProfileDetailsModel copyWith({
    String? image,
    String? name,
    String? phoneNumber,
    String? emailId,
    String? address,
    String? designation,
    String? joiningDate,
    String? dob,
  }) {
    return ProfileDetailsModel(
      image: image ?? this.image,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailId: emailId ?? this.emailId,
      address: address ?? this.address,
      designation: designation ?? this.designation,
      joiningDate: joiningDate ?? this.joiningDate,
      dob: dob ?? this.dob,
    );
  }
}
