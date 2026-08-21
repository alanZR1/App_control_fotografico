import '../domain/work.dart';

abstract interface class WorksRepository {
  Future<List<Work>> getAssignedWorks();
}

class MockWorksRepository implements WorksRepository {
  @override
  Future<List<Work>> getAssignedWorks() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return _works;
  }

  static final _works = [
    Work(
      id: 214,
      title: 'Rehabilitación de vivienda',
      beneficiary: 'María López',
      municipality: 'Tlacolula de Matamoros',
      stage: 'Proceso constructivo',
      completedEvidence: 14,
      totalEvidence: 18,
      pendingEvidence: 2,
      status: WorkStatus.inProgress,
      company: 'Constructora XYZ',
      address: 'Calle Hidalgo 24',
      stages: _activeStages,
    ),
    Work(
      id: 308,
      title: 'Mejoramiento de fachada',
      beneficiary: 'José Ramírez',
      municipality: 'Oaxaca de Juárez',
      stage: 'Terminación',
      completedEvidence: 20,
      totalEvidence: 24,
      pendingEvidence: 4,
      status: WorkStatus.pending,
      company: 'Construcciones del Sur',
      address: 'Av. Independencia 105',
      stages: _pendingStages,
    ),
    Work(
      id: 421,
      title: 'Ampliación de cuarto',
      beneficiary: 'Ana Cruz',
      municipality: 'Santa Lucía',
      stage: 'Antes de iniciar',
      completedEvidence: 5,
      totalEvidence: 5,
      pendingEvidence: 0,
      status: WorkStatus.completed,
      company: 'Obras Comunitarias SA',
      address: 'Calle Reforma 18',
      stages: _completedStages,
    ),
  ];

  static final _activeStages = [
    WorkStage(
      number: 1,
      name: 'Antes de iniciar',
      completed: 5,
      total: 5,
      status: StageStatus.completed,
      photoTypes: ['Fachada', 'Interior', 'Terreno', 'Acceso', 'Panorámica'],
    ),
    WorkStage(
      number: 2,
      name: 'Entrega de materiales',
      completed: 4,
      total: 4,
      status: StageStatus.completed,
      photoTypes: ['Materiales', 'Descarga', 'Beneficiario', 'Empresa'],
    ),
    WorkStage(
      number: 3,
      name: 'Inicio de obra',
      completed: 3,
      total: 3,
      status: StageStatus.completed,
      photoTypes: ['Excavación', 'Trazo', 'Cimentación'],
    ),
    WorkStage(
      number: 4,
      name: 'Proceso constructivo',
      completed: 2,
      total: 3,
      status: StageStatus.inProgress,
      photoTypes: ['Avance 25 %', 'Avance 50 %', 'Avance 75 %'],
    ),
    WorkStage(
      number: 5,
      name: 'Terminación',
      completed: 0,
      total: 4,
      status: StageStatus.locked,
      photoTypes: ['Obra terminada', 'Acabados', 'Fachada', 'Interiores'],
    ),
    WorkStage(
      number: 6,
      name: 'Entrega',
      completed: 0,
      total: 3,
      status: StageStatus.locked,
      photoTypes: ['Beneficiario', 'Firma', 'Recepción'],
    ),
  ];

  static final _pendingStages = [
    WorkStage(
      number: 1,
      name: 'Antes de iniciar',
      completed: 5,
      total: 5,
      status: StageStatus.completed,
      photoTypes: ['Fachada', 'Interior', 'Terreno', 'Acceso', 'Panorámica'],
    ),
    WorkStage(
      number: 2,
      name: 'Entrega de materiales',
      completed: 4,
      total: 4,
      status: StageStatus.completed,
      photoTypes: ['Materiales', 'Descarga', 'Beneficiario', 'Empresa'],
    ),
    WorkStage(
      number: 3,
      name: 'Inicio de obra',
      completed: 3,
      total: 3,
      status: StageStatus.completed,
      photoTypes: ['Excavación', 'Trazo', 'Cimentación'],
    ),
    WorkStage(
      number: 4,
      name: 'Proceso constructivo',
      completed: 3,
      total: 3,
      status: StageStatus.completed,
      photoTypes: ['Avance 25 %', 'Avance 50 %', 'Avance 75 %'],
    ),
    WorkStage(
      number: 5,
      name: 'Terminación',
      completed: 5,
      total: 8,
      status: StageStatus.inProgress,
      photoTypes: ['Obra terminada', 'Acabados', 'Fachada', 'Interiores'],
    ),
    WorkStage(
      number: 6,
      name: 'Entrega',
      completed: 0,
      total: 1,
      status: StageStatus.locked,
      photoTypes: ['Recepción'],
    ),
  ];

  static final _completedStages = [
    WorkStage(
      number: 1,
      name: 'Antes de iniciar',
      completed: 1,
      total: 1,
      status: StageStatus.completed,
      photoTypes: ['Fachada'],
    ),
    WorkStage(
      number: 2,
      name: 'Entrega de materiales',
      completed: 1,
      total: 1,
      status: StageStatus.completed,
      photoTypes: ['Materiales'],
    ),
    WorkStage(
      number: 3,
      name: 'Inicio de obra',
      completed: 1,
      total: 1,
      status: StageStatus.completed,
      photoTypes: ['Cimentación'],
    ),
    WorkStage(
      number: 4,
      name: 'Proceso constructivo',
      completed: 1,
      total: 1,
      status: StageStatus.completed,
      photoTypes: ['Avance'],
    ),
    WorkStage(
      number: 5,
      name: 'Terminación',
      completed: 1,
      total: 1,
      status: StageStatus.completed,
      photoTypes: ['Obra terminada'],
    ),
    WorkStage(
      number: 6,
      name: 'Entrega',
      completed: 0,
      total: 0,
      status: StageStatus.completed,
      photoTypes: ['Recepción'],
    ),
  ];
}
