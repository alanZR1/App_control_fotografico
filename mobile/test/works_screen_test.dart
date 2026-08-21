import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_imagenes/features/works/data/mock_works_repository.dart';
import 'package:mobile_imagenes/features/works/presentation/works_screen.dart';
import 'package:mobile_imagenes/features/photos/data/mock_photo_repository.dart';

void main() {
  Widget buildScreen() => MaterialApp(
    home: WorksScreen(
      repository: MockWorksRepository(),
      photoRepository: MockPhotoRepository(),
    ),
  );

  testWidgets('muestra las obras asignadas y permite buscarlas', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Rehabilitación de vivienda'), findsOneWidget);
    expect(find.text('Mejoramiento de fachada'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('worksSearchField')),
      'Ana Cruz',
    );
    await tester.pump();

    expect(find.text('Ampliación de cuarto'), findsOneWidget);
    expect(find.text('Rehabilitación de vivienda'), findsNothing);
  });

  testWidgets('filtra las obras terminadas', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byKey(const Key('filter-completed')));
    await tester.pump();

    expect(find.text('Ampliación de cuarto'), findsOneWidget);
    expect(find.text('Mejoramiento de fachada'), findsNothing);
  });

  testWidgets('abre el detalle de una obra', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byKey(const Key('work-214')));
    await tester.pumpAndSettle();

    expect(find.text('Detalle de obra'), findsOneWidget);
    expect(find.text('OB-00214'), findsOneWidget);
    expect(find.text('4. Proceso constructivo'), findsOneWidget);
    expect(find.byKey(const Key('addEvidenceButton')), findsOneWidget);
    expect(find.text('Avance 75 %'), findsOneWidget);
    expect(find.text('Agregar fotografía'), findsOneWidget);
  });

  testWidgets('abre la galería de evidencias de la etapa activa', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('work-214')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('addEvidenceButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Evidencia fotográfica'), findsOneWidget);
    expect(find.text('Avance 25 %'), findsOneWidget);
    expect(find.text('Avance 50 %'), findsOneWidget);
    expect(find.byKey(const Key('addPhotoButton')), findsOneWidget);
  });
}
