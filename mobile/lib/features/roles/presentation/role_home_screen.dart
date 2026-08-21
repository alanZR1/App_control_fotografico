import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/domain/user_session.dart';
import '../../auth/presentation/profile_screen.dart';
import '../../sync/data/local_operation_repository.dart';
import '../../sync/domain/offline_operation.dart';
import '../../sync/presentation/sync_center_screen.dart';
import '../../works/data/mock_works_repository.dart';
import '../../works/presentation/works_screen.dart';

class RoleHomeScreen extends StatelessWidget {
  const RoleHomeScreen({
    required this.session,
    required this.onLogout,
    super.key,
  });

  final UserSession session;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) => switch (session.role) {
    UserRole.contractor => _ContractorHome(
      session: session,
      onLogout: onLogout,
    ),
    UserRole.supervisor => _SupervisorHome(
      session: session,
      onLogout: onLogout,
    ),
    UserRole.beneficiary => _BeneficiaryHome(
      session: session,
      onLogout: onLogout,
    ),
    UserRole.executive => _ExecutiveHome(session: session, onLogout: onLogout),
  };
}

abstract class _RoleHome extends StatelessWidget {
  const _RoleHome({required this.session, required this.onLogout});
  final UserSession session;
  final VoidCallback onLogout;

  String get title;
  String get subtitle;
  List<Widget> buildContent(BuildContext context);

  void openWorks(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => WorksScreen(
        repository: MockWorksRepository(),
        session: session,
        onLogout: onLogout,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8FAFE),
    appBar: AppBar(
      toolbarHeight: 78,
      backgroundColor: AppColors.darkBlue,
      foregroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Centro de sincronización',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const SyncCenterScreen()),
          ),
          icon: const Icon(Icons.cloud_sync_outlined),
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
      children: [
        Text(
          'Hola, ${session.name.split(' ').first}',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          session.roleLabel,
          style: const TextStyle(
            color: AppColors.blue,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        ...buildContent(context),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        if (index == 1) openWorks(context);
        if (index == 2) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ProfileScreen(
                session: session,
                onLogout: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  onLogout();
                },
              ),
            ),
          );
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Inicio'),
        NavigationDestination(
          icon: Icon(Icons.apartment_rounded),
          label: 'Obras',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Perfil',
        ),
      ],
    ),
  );
}

class _ContractorHome extends _RoleHome {
  const _ContractorHome({required super.session, required super.onLogout});
  @override
  String get title => 'Panel del contratista';
  @override
  String get subtitle => 'Obras, evidencias y requerimientos';

  @override
  List<Widget> buildContent(BuildContext context) => [
    const _SectionTitle('Siguiente tarea'),
    _TaskCard(
      color: AppColors.danger,
      icon: Icons.refresh_rounded,
      title: 'Repetir Avance 50 %',
      subtitle: 'OB-00214 · La imagen está borrosa',
      status: 'Rechazada',
      onTap: () => openWorks(context),
    ),
    const SizedBox(height: 14),
    const _MetricRow(
      items: [
        _Metric(
          'Obras asignadas',
          '3',
          Icons.apartment_rounded,
          AppColors.blue,
        ),
        _Metric(
          'Pendientes',
          '2',
          Icons.pending_actions_rounded,
          AppColors.warning,
        ),
        _Metric('Rechazadas', '1', Icons.cancel_outlined, AppColors.danger),
      ],
    ),
    const SizedBox(height: 18),
    _PrimaryAction(
      icon: Icons.apartment_rounded,
      title: 'Mis obras',
      subtitle: 'Captura y consulta evidencias',
      onTap: () => openWorks(context),
    ),
    const SizedBox(height: 20),
    const _SectionTitle('Otros requerimientos'),
    _TaskCard(
      color: AppColors.warning,
      icon: Icons.add_a_photo_outlined,
      title: 'Agregar Avance 75 %',
      subtitle: 'OB-00214 · Proceso constructivo',
      status: 'Pendiente',
      onTap: () => openWorks(context),
    ),
    const SizedBox(height: 12),
    const _SectionTitle('Observaciones recientes'),
    const _InfoCard(
      icon: Icons.comment_outlined,
      title: 'Supervisor · OB-00214',
      body: 'Repetir la fotografía mostrando completa la fachada y el acceso.',
    ),
  ];
}

class _SupervisorHome extends _RoleHome {
  const _SupervisorHome({required super.session, required super.onLogout});
  @override
  String get title => 'Panel del supervisor';
  @override
  String get subtitle => 'Captura, visitas y validaciones';

  @override
  List<Widget> buildContent(BuildContext context) => [
    const _SectionTitle('Revisar siguiente evidencia'),
    _ValidationCard(
      userId: session.userId,
      workId: 214,
      type: 'Avance 50 %',
      work: 'OB-00214 · Rehabilitación de vivienda',
      metadata: 'María López · Hoy, 16:28 · Ubicación verificada',
    ),
    const SizedBox(height: 14),
    const _MetricRow(
      items: [
        _Metric('Obras', '6', Icons.apartment_rounded, AppColors.blue),
        _Metric(
          'Por validar',
          '4',
          Icons.fact_check_outlined,
          AppColors.warning,
        ),
        _Metric(
          'Visitas hoy',
          '2',
          Icons.location_on_outlined,
          AppColors.success,
        ),
      ],
    ),
    const SizedBox(height: 18),
    Row(
      children: [
        Expanded(
          child: _PrimaryAction(
            icon: Icons.apartment_rounded,
            title: 'Mis obras',
            subtitle: 'Obras asignadas',
            onTap: () => openWorks(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PrimaryAction(
            icon: Icons.add_location_alt_outlined,
            title: 'Registrar visita',
            subtitle: 'Fecha y ubicación',
            onTap: () => _showVisitDialog(context),
          ),
        ),
      ],
    ),
    const SizedBox(height: 22),
    const _SectionTitle('Después en la lista'),
    _ValidationCard(
      userId: session.userId,
      workId: 308,
      type: 'Fachada',
      work: 'OB-00308 · Mejoramiento de fachada',
      metadata: 'José Ramírez · Ayer, 12:10 · Ubicación verificada',
    ),
  ];

  Future<void> _showVisitDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar visita'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Selecciona o escribe una obra.'
                    : null,
                decoration: InputDecoration(
                  labelText: 'Obra',
                  prefixIcon: Icon(Icons.apartment_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                maxLines: 3,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Describe brevemente la visita.'
                    : null,
                decoration: const InputDecoration(labelText: 'Notas de visita'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (saved == true && context.mounted) {
      await LocalOperationRepository.instance.enqueue(
        type: OfflineOperationType.visit,
        workId: 214,
        userId: session.userId,
        description: 'Visita registrada',
        payload: const {'source': 'mobile'},
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Visita guardada localmente. Pendiente de sincronización.',
          ),
        ),
      );
    }
  }
}

class _BeneficiaryHome extends _RoleHome {
  const _BeneficiaryHome({required super.session, required super.onLogout});
  @override
  String get title => 'Mi obra';
  @override
  String get subtitle => 'Avance y evidencias de tu vivienda';

  @override
  List<Widget> buildContent(BuildContext context) => [
    _WorkProgressCard(onTap: () => openWorks(context)),
    const SizedBox(height: 20),
    const _SectionTitle('Acciones disponibles'),
    _ProgressConfirmationAction(userId: session.userId),
    const SizedBox(height: 12),
    _PrimaryAction(
      icon: Icons.draw_outlined,
      title: 'Firma de recepción',
      subtitle: 'Disponible al terminar la obra',
      enabled: false,
      onTap: () {},
    ),
    const SizedBox(height: 20),
    const _SectionTitle('Solicitud de fotografía'),
    _TaskCard(
      color: AppColors.warning,
      icon: Icons.add_a_photo_outlined,
      title: 'Fotografía del beneficiario',
      subtitle: 'Entrega de materiales · OB-00214',
      status: 'Solicitada',
      onTap: () => openWorks(context),
    ),
    const _InfoCard(
      icon: Icons.info_outline_rounded,
      title: 'Sólo ves tu obra',
      body: 'Las acciones disponibles son las autorizadas por tu supervisor.',
    ),
  ];
}

class _ExecutiveHome extends _RoleHome {
  const _ExecutiveHome({required super.session, required super.onLogout});
  @override
  String get title => 'Panel ejecutivo';
  @override
  String get subtitle => 'Consulta global, indicadores y reportes';

  @override
  List<Widget> buildContent(BuildContext context) => [
    const _MetricRow(
      items: [
        _Metric('Obras', '18', Icons.apartment_rounded, AppColors.blue),
        _Metric(
          'Por validar',
          '24',
          Icons.fact_check_outlined,
          AppColors.warning,
        ),
        _Metric('Terminadas', '7', Icons.flag_outlined, AppColors.success),
      ],
    ),
    const SizedBox(height: 18),
    const _SectionTitle('Indicadores prioritarios'),
    const _IndicatorRow(
      label: 'Obras con evidencia completa',
      value: '11',
      color: AppColors.success,
    ),
    const _IndicatorRow(
      label: 'Obras sin fotografías',
      value: '4',
      color: AppColors.warning,
    ),
    const _IndicatorRow(
      label: 'Fotografías rechazadas',
      value: '5',
      color: AppColors.danger,
    ),
    const SizedBox(height: 18),
    Row(
      children: [
        Expanded(
          child: _PrimaryAction(
            icon: Icons.apartment_rounded,
            title: 'Todas las obras',
            subtitle: 'Consulta global',
            onTap: () => openWorks(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PrimaryAction(
            icon: Icons.picture_as_pdf_outlined,
            title: 'Reportes',
            subtitle: 'Expedientes PDF',
            onTap: () => _showReports(context),
          ),
        ),
      ],
    ),
    const SizedBox(height: 22),
    const _SectionTitle('Consultar obras'),
    _ExecutiveFilters(
      onApply: () => ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Se encontraron 8 obras.'))),
    ),
  ];

  void _showReports(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reportes disponibles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            ListTile(
              onTap: () =>
                  _reportPending(context, sheetContext, 'Reporte por obra'),
              leading: const Icon(Icons.apartment_outlined),
              title: const Text('Reporte por obra'),
              trailing: const Icon(Icons.chevron_right),
            ),
            ListTile(
              onTap: () =>
                  _reportPending(context, sheetContext, 'Reporte por empresa'),
              leading: const Icon(Icons.business_outlined),
              title: const Text('Reporte por empresa'),
              trailing: const Icon(Icons.chevron_right),
            ),
            ListTile(
              onTap: () => _reportPending(
                context,
                sheetContext,
                'Reporte por municipio',
              ),
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Reporte por municipio'),
              trailing: const Icon(Icons.chevron_right),
            ),
            ListTile(
              onTap: () => _reportPending(
                context,
                sheetContext,
                'Expediente fotográfico PDF',
              ),
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('Expediente fotográfico PDF'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    ),
  );

  void _reportPending(
    BuildContext context,
    BuildContext sheetContext,
    String report,
  ) {
    Navigator.pop(sheetContext);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$report estará disponible al conectar el backend.'),
      ),
    );
  }
}

class _Metric {
  const _Metric(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.items});
  final List<_Metric> items;
  @override
  Widget build(BuildContext context) => Row(
    children: items
        .map(
          (item) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Icon(item.icon, color: item.color),
                  const SizedBox(height: 5),
                  Text(
                    item.value,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: item.color,
                    ),
                  ),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList(),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
    ),
  );
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;
  @override
  Widget build(BuildContext context) => Material(
    color: enabled ? Colors.white : const Color(0xFFF0F2F5),
    borderRadius: BorderRadius.circular(15),
    child: InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.paleBlue,
              child: Icon(
                icon,
                color: enabled ? AppColors.blue : AppColors.muted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            if (enabled)
              const Icon(Icons.chevron_right_rounded)
            else
              const Tooltip(
                message: 'Disponible al completar la obra',
                child: Icon(Icons.lock_outline_rounded, color: AppColors.muted),
              ),
          ],
        ),
      ),
    ),
  );
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    this.onTap,
  });
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: .12),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (onTap != null) const Icon(Icons.chevron_right_rounded),
        ],
      ),
    ),
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon, color: AppColors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(body),
    ),
  );
}

enum _ValidationDecision { pending, approved, rejected }

class _ValidationCard extends StatefulWidget {
  const _ValidationCard({
    required this.userId,
    required this.workId,
    required this.type,
    required this.work,
    required this.metadata,
  });
  final int userId;
  final int workId;
  final String type;
  final String work;
  final String metadata;

  @override
  State<_ValidationCard> createState() => _ValidationCardState();
}

class _ValidationCardState extends State<_ValidationCard> {
  _ValidationDecision decision = _ValidationDecision.pending;
  String? operationId;

  @override
  void initState() {
    super.initState();
    _restoreDecision();
  }

  Future<void> _restoreDecision() async {
    final items = await LocalOperationRepository.instance.getAll();
    for (final item in items) {
      if (item.workId != widget.workId) continue;
      if (item.type == OfflineOperationType.approveEvidence ||
          item.type == OfflineOperationType.rejectEvidence) {
        if (!mounted) return;
        setState(() {
          operationId = item.id;
          decision = item.type == OfflineOperationType.approveEvidence
              ? _ValidationDecision.approved
              : _ValidationDecision.rejected;
        });
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 112,
            decoration: BoxDecoration(
              color: AppColors.paleBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.photo_outlined,
                size: 48,
                color: AppColors.blue,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.type,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          Text(widget.work, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 4),
          Text(
            widget.metadata,
            style: const TextStyle(fontSize: 14, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          if (decision == _ValidationDecision.pending)
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _approve,
                    icon: const Icon(Icons.check),
                    label: const Text('Aprobar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _reject,
                    icon: const Icon(Icons.close),
                    label: const Text('Rechazar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                    ),
                  ),
                ),
              ],
            )
          else
            _DecisionStatus(
              approved: decision == _ValidationDecision.approved,
              onUndo: _undo,
            ),
        ],
      ),
    ),
  );

  Future<void> _reject() async {
    final formKey = GlobalKey<FormState>();
    final observationController = TextEditingController();
    final rejected = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rechazar evidencia'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: observationController,
            autofocus: true,
            maxLines: 4,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Escribe el motivo del rechazo.'
                : null,
            decoration: const InputDecoration(
              labelText: 'Observación obligatoria',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
    if (rejected == true && mounted) {
      final operation = await LocalOperationRepository.instance.enqueue(
        type: OfflineOperationType.rejectEvidence,
        workId: widget.workId,
        userId: widget.userId,
        description: '${widget.type} rechazada',
        payload: {'observation': observationController.text.trim()},
      );
      operationId = operation.id;
      setState(() => decision = _ValidationDecision.rejected);
    }
    observationController.dispose();
  }

  Future<void> _approve() async {
    final operation = await LocalOperationRepository.instance.enqueue(
      type: OfflineOperationType.approveEvidence,
      workId: widget.workId,
      userId: widget.userId,
      description: '${widget.type} aprobada',
      payload: {'evidenceType': widget.type},
    );
    operationId = operation.id;
    if (mounted) setState(() => decision = _ValidationDecision.approved);
  }

  Future<void> _undo() async {
    final id = operationId;
    if (id != null) await LocalOperationRepository.instance.delete(id);
    if (mounted) {
      setState(() {
        operationId = null;
        decision = _ValidationDecision.pending;
      });
    }
  }
}

class _DecisionStatus extends StatelessWidget {
  const _DecisionStatus({required this.approved, required this.onUndo});
  final bool approved;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final color = approved ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(approved ? Icons.check_circle : Icons.cancel, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              approved ? 'Aprobada localmente' : 'Rechazada localmente',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(onPressed: onUndo, child: const Text('Deshacer')),
        ],
      ),
    );
  }
}

class _WorkProgressCard extends StatelessWidget {
  const _WorkProgressCard({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rehabilitación de vivienda',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
            Text(
              'OB-00214 · María López',
              style: TextStyle(color: AppColors.muted),
            ),
            SizedBox(height: 18),
            Row(
              children: [
                Text('Avance fotográfico'),
                Spacer(),
                Text(
                  '78 %',
                  style: TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(value: .78, minHeight: 9),
            SizedBox(height: 10),
            Text(
              '14 de 18 evidencias',
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ProgressConfirmationAction extends StatefulWidget {
  const _ProgressConfirmationAction({required this.userId});
  final int userId;

  @override
  State<_ProgressConfirmationAction> createState() =>
      _ProgressConfirmationActionState();
}

class _ProgressConfirmationActionState
    extends State<_ProgressConfirmationAction> {
  bool confirmed = false;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final items = await LocalOperationRepository.instance.getAll();
    final exists = items.any(
      (item) =>
          item.workId == 214 &&
          item.type == OfflineOperationType.confirmProgress,
    );
    if (mounted) setState(() => confirmed = exists);
  }

  @override
  Widget build(BuildContext context) => confirmed
      ? const _InfoCard(
          icon: Icons.verified_rounded,
          title: 'Avance confirmado',
          body: 'Guardado localmente y pendiente de sincronización.',
        )
      : _PrimaryAction(
          icon: Icons.check_circle_outline_rounded,
          title: 'Confirmar avance',
          subtitle: 'Confirma que reconoces el avance del 50 %',
          onTap: _confirm,
        );

  Future<void> _confirm() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar avance'),
        content: const Text(
          'Obra OB-00214 · Proceso constructivo\n\nAl confirmar indicas que reconoces haber visto el avance fotográfico del 50 %. Esto no sustituye la validación técnica del supervisor.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (accepted != true) return;
    await LocalOperationRepository.instance.enqueue(
      type: OfflineOperationType.confirmProgress,
      workId: 214,
      userId: widget.userId,
      description: 'Avance del 50 % confirmado',
      payload: const {'progress': 50},
    );
    if (!mounted) return;
    setState(() => confirmed = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avance confirmado y guardado localmente.')),
    );
  }
}

class _ExecutiveFilters extends StatefulWidget {
  const _ExecutiveFilters({required this.onApply});
  final VoidCallback onApply;

  @override
  State<_ExecutiveFilters> createState() => _ExecutiveFiltersState();
}

class _ExecutiveFiltersState extends State<_ExecutiveFilters> {
  String municipality = 'Todos';
  String company = 'Todas';
  String supervisor = 'Todos';
  String status = 'Todos';

  bool get hasFilters =>
      municipality != 'Todos' ||
      company != 'Todas' ||
      supervisor != 'Todos' ||
      status != 'Todos';

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Filtros',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _FilterField(
                label: 'Municipio',
                value: municipality,
                options: const ['Todos', 'Tlacolula', 'Oaxaca de Juárez'],
                onChanged: (value) => setState(() => municipality = value),
              ),
              _FilterField(
                label: 'Empresa',
                value: company,
                options: const ['Todas', 'Constructora XYZ', 'Obras del Sur'],
                onChanged: (value) => setState(() => company = value),
              ),
              _FilterField(
                label: 'Supervisor',
                value: supervisor,
                options: const ['Todos', 'Juan Pérez', 'Laura Díaz'],
                onChanged: (value) => setState(() => supervisor = value),
              ),
              _FilterField(
                label: 'Estatus',
                value: status,
                options: const [
                  'Todos',
                  'En proceso',
                  'Terminadas',
                  'Pendientes',
                ],
                onChanged: (value) => setState(() => status = value),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasFilters)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _clear,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Limpiar filtros'),
              ),
            ),
          FilledButton.icon(
            onPressed: widget.onApply,
            icon: Icon(Icons.filter_alt_outlined),
            label: Text('Aplicar filtros'),
          ),
        ],
      ),
    ),
  );
  void _clear() => setState(() {
    municipality = 'Todos';
    company = 'Todas';
    supervisor = 'Todos';
    status = 'Todos';
  });
}

class _FilterField extends StatelessWidget {
  const _FilterField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 145,
    child: DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: options
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    ),
  );
}

class _IndicatorRow extends StatelessWidget {
  const _IndicatorRow({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(Icons.analytics_outlined, color: color),
      title: Text(label),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    ),
  );
}
