import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id, email, name, role;
  final Map<String, dynamic> profile;
  final bool emailVerified;
  const UserModel({required this.id, required this.email, required this.name, required this.role, this.profile = const {}, this.emailVerified = true});

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(id: j['id'], email: j['email'], name: j['name'] ?? '', role: j['role'] ?? 'user', profile: Map<String, dynamic>.from(j['profile'] ?? {}), emailVerified: j['email_verified'] ?? true);
  bool get isAdmin => role == 'admin';
  List<String> listOf(String k) => ((profile[k] as List?) ?? []).map((e) => e.toString()).toList();
  @override
  List<Object?> get props => [id, email, name, role, profile, emailVerified];
}

class AuthResponse {
  final String accessToken, refreshToken;
  final UserModel user;
  AuthResponse({required this.accessToken, required this.refreshToken, required this.user});
  factory AuthResponse.fromJson(Map<String, dynamic> j) => AuthResponse(accessToken: j['access_token'], refreshToken: j['refresh_token'], user: UserModel.fromJson(j['user']));
}
