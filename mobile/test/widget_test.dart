import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_imagenes/features/auth/data/mock_auth_service.dart';
import 'package:mobile_imagenes/features/auth/presentation/login_screen.dart';
import 'package:mobile_imagenes/app.dart';

void main() {
  Widget buildLogin() =>
      MaterialApp(home: LoginScreen(authService: MockAuthService()));

  testWidgets('muestra y valida el formulario de inicio de sesión', (
    tester,
  ) async {
    await tester.pumpWidget(buildLogin());

    expect(find.text('Control Fotográfico de Obras'), findsOneWidget);
    expect(find.byKey(const Key('emailField')), findsOneWidget);
    expect(find.byKey(const Key('passwordField')), findsOneWidget);

    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump();

    expect(find.text('Ingresa tu correo.'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
  });

  testWidgets('navega a Mis obras con las credenciales simuladas', (
    tester,
  ) async {
    await tester.pumpWidget(const ControlFotograficoApp());
    await tester.enterText(
      find.byKey(const Key('emailField')),
      MockAuthService.demoEmail,
    );
    await tester.enterText(
      find.byKey(const Key('passwordField')),
      MockAuthService.demoPassword,
    );
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Panel del supervisor'), findsOneWidget);
    expect(find.text('Revisar siguiente evidencia'), findsOneWidget);
    expect(find.text('Supervisor'), findsOneWidget);
  });
}
