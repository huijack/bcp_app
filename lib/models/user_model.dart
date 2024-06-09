class UserModel {
  final String? id;
  final String? fullName;
  final String? email;
  final String? password; // Note: Avoid storing passwords in plain text for security reasons.

  const UserModel({
    this.id,
    this.fullName,
    this.email,
    this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "fullName": fullName,
      "email": email,
      // Do not store password in Firestore in real applications
      // Use Firebase Authentication for managing passwords securely
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      // Do not retrieve password in real applications
    );
  }
}
