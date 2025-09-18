/// Model representing user session data
class UserSession {
  final String username;
  final List<String> roles;
  
  const UserSession({
    required this.username,
    required this.roles,
  });
  
  /// Check if user has a specific role
  bool hasRole(String role) {
    return roles.contains(role);
  }
  
  /// Check if user is an admin
  bool isAdmin() {
    return hasRole('ROLE_ADMIN');
  }
  
  /// Check if user is a regular user
  bool isUser() {
    return hasRole('ROLE_USER');
  }
  
  /// Create UserSession from API response
  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      username: json['username'] as String,
      roles: (json['roles'] as List<dynamic>?)
          ?.map((role) => role.toString())
          .toList() ?? [],
    );
  }
  
  /// Convert UserSession to JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'roles': roles,
    };
  }
  
  @override
  String toString() {
    return 'UserSession(username: $username, roles: $roles)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UserSession) return false;
    return username == other.username && 
           roles.length == other.roles.length &&
           roles.every((role) => other.roles.contains(role));
  }
  
  @override
  int get hashCode => Object.hash(username, roles);
}