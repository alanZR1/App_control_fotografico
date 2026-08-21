import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../photos/data/mock_photo_repository.dart';
import '../../photos/presentation/evidence_gallery_screen.dart';
import '../../photos/presentation/photo_capture_screen.dart';
import '../domain/work.dart';

class WorkDetailScreen extends StatelessWidget {
  const WorkDetailScreen({
    required this.work,
    required this.photoRepository,
    this.allowCapture = true,
    super.key,
  });

  final Work work;
  final PhotoRepository photoRepository;
  final bool allowCapture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFE),
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        title: const Text('Detalle de obra'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: AppColors.paleBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  size: 42,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  work.title,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _InformationCard(work: work),
          const SizedBox(height: 18),
          _ProgressCard(work: work),
          const SizedBox(height: 18),
          ...work.stages.map(
            (stage) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _StageTile(
                stage: stage,
                work: work,
                photoRepository: photoRepository,
                allowCapture: allowCapture,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index != 1) Navigator.of(context).pop();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.apartment_rounded),
            label: 'Obras',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            label: 'Validaciones',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({required this.work});
  final Work work;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _Info(
                  icon: Icons.description_outlined,
                  label: 'Folio',
                  value: work.folio,
                ),
              ),
              Expanded(
                child: _Info(
                  icon: Icons.person_outline,
                  label: 'Beneficiario',
                  value: work.beneficiary,
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          Row(
            children: [
              Expanded(
                child: _Info(
                  icon: Icons.business_center_outlined,
                  label: 'Empresa',
                  value: work.company,
                ),
              ),
              Expanded(
                child: _Info(
                  icon: Icons.location_on_outlined,
                  label: 'Municipio',
                  value: work.municipality,
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          _Info(
            icon: Icons.map_outlined,
            label: 'Dirección',
            value: work.address,
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.work});
  final Work work;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          const CircleAvatar(
            radius: 27,
            backgroundColor: AppColors.paleBlue,
            child: Icon(
              Icons.photo_camera_outlined,
              color: AppColors.blue,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Evidencia fotográfica',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  '${work.completedEvidence} de ${work.totalEvidence} fotografías completadas',
                  style: const TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: work.progress,
                    minHeight: 8,
                    color: AppColors.blue,
                    backgroundColor: const Color(0xFFE4E8F0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            '${work.progressPercent}%',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

class _StageTile extends StatefulWidget {
  const _StageTile({
    required this.stage,
    required this.work,
    required this.photoRepository,
    required this.allowCapture,
  });
  final WorkStage stage;
  final Work work;
  final PhotoRepository photoRepository;
  final bool allowCapture;

  @override
  State<_StageTile> createState() => _StageTileState();
}

class _StageTileState extends State<_StageTile> {
  late final Map<int, RequirementStatus> _statuses = {
    for (final requirement in widget.stage.requirements)
      requirement.typeId: requirement.status,
  };

  WorkStage get stage => widget.stage;
  Work get work => widget.work;

  Color get color => switch (stage.status) {
    StageStatus.completed => AppColors.success,
    StageStatus.inProgress => AppColors.blue,
    StageStatus.pending => AppColors.warning,
    StageStatus.locked => const Color(0xFF7B8495),
  };

  IconData get icon => switch (stage.status) {
    StageStatus.completed => Icons.check_rounded,
    StageStatus.inProgress => Icons.schedule_rounded,
    StageStatus.pending => Icons.pending_actions_rounded,
    StageStatus.locked => Icons.lock_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final enabled = stage.status != StageStatus.locked;
    return _Card(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        key: Key('stage-${stage.number}'),
        initiallyExpanded: stage.status == StageStatus.inProgress,
        enabled: enabled,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        childrenPadding: const EdgeInsets.fromLTRB(70, 0, 16, 16),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(
          '${stage.number}. ${stage.name}',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: enabled ? AppColors.text : AppColors.muted,
          ),
        ),
        subtitle: stage.status == StageStatus.inProgress
            ? const Text('En progreso', style: TextStyle(color: AppColors.blue))
            : null,
        trailing: SizedBox(
          width: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${stage.completed} / ${stage.total}',
                style: TextStyle(fontWeight: FontWeight.w800, color: color),
              ),
              const SizedBox(width: 5),
              Icon(
                enabled
                    ? Icons.expand_more_rounded
                    : Icons.lock_outline_rounded,
                color: color,
              ),
            ],
          ),
        ),
        children: [
          ...stage.requirements.map(
            (requirement) => _RequirementRow(
              requirement: requirement,
              status: _statuses[requirement.typeId]!,
              canCapture: widget.allowCapture,
              onTap: () => _openRequirement(context, requirement),
            ),
          ),
          if (stage.status == StageStatus.inProgress)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const Key('addEvidenceButton'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => EvidenceGalleryScreen(
                      work: work,
                      stage: stage,
                      repository: widget.photoRepository,
                    ),
                  ),
                ),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Ver galería de la etapa'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openRequirement(
    BuildContext context,
    PhotoRequirement requirement,
  ) async {
    final status = _statuses[requirement.typeId]!;
    if (status != RequirementStatus.missing &&
        status != RequirementStatus.rejected) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => EvidenceGalleryScreen(
            work: work,
            stage: stage,
            repository: widget.photoRepository,
          ),
        ),
      );
      return;
    }

    if (!widget.allowCapture) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu rol no permite capturar evidencias.')),
      );
      return;
    }

    final evidence = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PhotoCaptureScreen(
          work: work,
          stage: stage,
          initialType: requirement.name,
          photoRepository: widget.photoRepository,
        ),
      ),
    );
    if (!mounted || evidence == null) return;
    setState(() => _statuses[requirement.typeId] = RequirementStatus.pending);
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({
    required this.requirement,
    required this.status,
    required this.onTap,
    required this.canCapture,
  });

  final PhotoRequirement requirement;
  final RequirementStatus status;
  final VoidCallback onTap;
  final bool canCapture;

  @override
  Widget build(BuildContext context) {
    final (icon, color, action) = switch (status) {
      RequirementStatus.missing => (
        Icons.add_circle_outline_rounded,
        canCapture ? AppColors.blue : AppColors.muted,
        canCapture ? 'Agregar fotografía' : 'Sólo consulta',
      ),
      RequirementStatus.pending => (
        Icons.cloud_upload_outlined,
        AppColors.warning,
        'Pendiente',
      ),
      RequirementStatus.synchronized => (
        Icons.check_circle_outline_rounded,
        AppColors.success,
        'Ver fotografía',
      ),
      RequirementStatus.approved => (
        Icons.verified_outlined,
        AppColors.success,
        'Aprobada',
      ),
      RequirementStatus.rejected => (
        Icons.cancel_outlined,
        AppColors.danger,
        'Repetir fotografía',
      ),
    };
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('requirement-${requirement.typeId}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: color, size: 23),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  requirement.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                action,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.all(18)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E7F0)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0E17345C),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: AppColors.blue, size: 26),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ],
  );
}
