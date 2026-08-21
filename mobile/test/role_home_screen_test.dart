import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_imagenes/features/auth/domain/user_session.dart';
import 'package:mobile_imagenes/features/roles/presentation/role_home_screen.dart';

void main() {
  Future<void> pumpRole(WidgetTester tester, UserRole role) =>
      tester.pumpWidget(
        MaterialApp(
          home: RoleHomeScreen(
            session: UserSession(
              userId: 1,
              name: 'Usuario Demo',
              email: 'demo@test.com',
              role: role,
            ),
            onLogout: () {},
          ),
        ),
      );

  testWidgets('muestra el panel del contratista', (tester) async {
    await pumpRole(tester, UserRole.contractor);
    expect(find.text('Panel del contratista'), findsOneWidget);
    expect(find.text('Siguiente tarea'), findsOneWidget);
  });

  testWidgets('muestra el panel del supervisor', (tester) async {
    await pumpRole(tester, UserRole.supervisor);
    expect(find.text('Panel del supervisor'), findsOneWidget);
    expect(find.text('Revisar siguiente evidencia'), findsOneWidget);
  });

  testWidgets('muestra el panel del beneficiario', (tester) async {
    await pumpRole(tester, UserRole.beneficiary);
    expect(find.text('Mi obra'), findsOneWidget);
    expect(find.text('Confirmar avance'), findsOneWidget);
  });

  testWidgets('muestra el panel ejecutivo', (tester) async {
    await pumpRole(tester, UserRole.executive);
    expect(find.text('Panel ejecutivo'), findsOneWidget);
    expect(find.text('Filtros'), findsOneWidget);
  });
}
