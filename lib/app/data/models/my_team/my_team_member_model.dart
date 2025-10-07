class TeamMember {
  final String name;
  final String phoneNumber;
  final String email;
  final String address;
  final String designation;
  final String joiningDate;
  final String dob;

  TeamMember({
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.designation,
    required this.joiningDate,
    required this.dob,
  });

  // Convert JSON to TeamMember object
  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      designation: json['designation'] ?? '',
      joiningDate: json['joiningDate'] ?? '',
      dob: json['dob'] ?? '',
    );
  }

  // Convert TeamMember object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'designation': designation,
      'joiningDate': joiningDate,
      'dob': dob,
    };
  }
}