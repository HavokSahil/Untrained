enum Role {
  admin,
  user
}

class User {
  final String email;
  final String name;
  final Role role;

  User({
    required this.name,
    required this.email,
    required this.role
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      role: json['role'] == 'ADMIN'? Role.admin: Role.user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role.toString()
    };
  }

  bool isAdmin() {
    return role == Role.admin;
  }
}