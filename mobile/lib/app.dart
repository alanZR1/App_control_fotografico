import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/config/app_environment.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/api_auth_service.dart';
import 'features/auth/data/mock_auth_service.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/domain/user_session.dart';
import 'features/roles/presentation/role_home_screen.dart';

class ControlFotograficoApp extends StatefulWidget {
  const ControlFotograficoApp({super.key});

  @override
  State<ControlFotograficoApp> createState() => _ControlFotograficoAppState();
}

class _ControlFotograficoAppState extends State<ControlFotograficoApp> {
  UserSession? _session;
  late final ApiClient _apiClient = ApiClient(baseUrl: AppConfig.apiBaseUrl);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control Fotográfico de Obras',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _session == null
          ? LoginScreen(
              authService: AppConfig.useMockServices
                  ? MockAuthService()
                  : ApiAuthService(_apiClient),
              onAuthenticated: (session) => setState(() => _session = session),
            )
          : RoleHomeScreen(
              session: _session!,
              onLogout: () => setState(() => _session = null),
            ),
    );
  }
}
