import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/user_session.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.session,
    required this.onLogout,
    super.key,
  });
  final UserSession session;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: AppColors.darkBlue,
      foregroundColor: Colors.white,
      title: const Text('Perfil'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const CircleAvatar(
          radius: 48,
          backgroundColor: AppColors.paleBlue,
          child: Icon(Icons.person_rounded, size: 56, color: AppColors.blue),
        ),
        const SizedBox(height: 18),
        Text(
          session.name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 5),
        Text(
          session.roleLabel,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.blue,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 28),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Correo'),
                subtitle: Text(session.email),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Rol'),
                subtitle: Text(session.roleLabel),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        OutlinedButton.icon(
          key: const Key('logoutButton'),
          onPressed: onLogout,
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Cerrar sesión'),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
        ),
      ],
    ),
  );
}
