enum UserRole { contractor, supervisor, beneficiary, executive }

enum Permission {
  viewAssignedWorks,
  viewAllWorks,
  captureEvidence,
  viewObservations,
  addressRequirements,
  validateEvidence,
  approveEvidence,
  rejectEvidence,
  confirmProgress,
  signReception,
  generateReports,
}

class UserSession {
  const UserSession({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.workId,
    this.token,
  });

  final int userId;
  final String name;
  final String email;
  final UserRole role;
  final int? workId;
  final String? token;

  String get roleLabel => switch (role) {
    UserRole.contractor => 'Contratista',
    UserRole.supervisor => 'Supervisor',
    UserRole.beneficiary => 'Beneficiario',
    UserRole.executive => 'Ejecutivo',
  };

  bool can(Permission permission) =>
      _rolePermissions[role]!.contains(permission);
}

const _rolePermissions = <UserRole, Set<Permission>>{
  UserRole.contractor: {
    Permission.viewAssignedWorks,
    Permission.captureEvidence,
    Permission.viewObservations,
    Permission.addressRequirements,
  },
  UserRole.supervisor: {
    Permission.viewAssignedWorks,
    Permission.captureEvidence,
    Permission.viewObservations,
    Permission.validateEvidence,
    Permission.approveEvidence,
    Permission.rejectEvidence,
  },
  UserRole.beneficiary: {
    Permission.viewAssignedWorks,
    Permission.captureEvidence,
    Permission.viewObservations,
    Permission.confirmProgress,
    Permission.signReception,
  },
  UserRole.executive: {
    Permission.viewAllWorks,
    Permission.viewObservations,
    Permission.validateEvidence,
    Permission.approveEvidence,
    Permission.rejectEvidence,
    Permission.generateReports,
  },
};
