// lib/app/data/models/executive/executive_model.dart
class ExecutiveModel {
  final String id;
  final String name;
  final String mobile;
  final String designation;
  final String? image;
  bool isSelected;

  ExecutiveModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.designation,
    this.image,
    this.isSelected = false,
  });

  ExecutiveModel copyWith({
    String? id,
    String? name,
    String? mobile,
    String? designation,
    String? image,
    bool? isSelected,
  }) {
    return ExecutiveModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      designation: designation ?? this.designation,
      image: image ?? this.image,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}