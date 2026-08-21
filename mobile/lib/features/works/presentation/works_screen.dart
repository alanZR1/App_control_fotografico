import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/connectivity/connectivity_banner.dart';
import '../data/mock_works_repository.dart';
import '../domain/work.dart';
import 'work_detail_screen.dart';
import '../../photos/data/local_photo_repository.dart';
import '../../photos/data/mock_photo_repository.dart';
import '../../auth/domain/user_session.dart';
import '../../auth/presentation/profile_screen.dart';

enum WorkFilter { all, inProgress, completed, pending }

class WorksScreen extends StatefulWidget {
  const WorksScreen({
    required this.repository,
    this.photoRepository,
    this.session,
    this.onLogout,
    super.key,
  });

  final WorksRepository repository;
  final PhotoRepository? photoRepository;
  final UserSession? session;
  final VoidCallback? onLogout;

  @override
  State<WorksScreen> createState() => _WorksScreenState();
}

class _WorksScreenState extends State<WorksScreen> {
  final _searchController = TextEditingController();
  WorkFilter _filter = WorkFilter.all;
  late Future<List<Work>> _worksFuture;

  @override
  void initState() {
    super.initState();
    _worksFuture = widget.repository.getAssignedWorks();
    _searchController.addListener(_refresh);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _retry() => setState(() {
    _worksFuture = widget.repository.getAssignedWorks();
  });

  List<Work> _filtered(List<Work> works) {
    final query = _searchController.text.trim().toLowerCase();
    return works.where((work) {
      final matchesQuery =
          query.isEmpty ||
          work.title.toLowerCase().contains(query) ||
          work.beneficiary.toLowerCase().contains(query) ||
          work.municipality.toLowerCase().contains(query);
      final matchesFilter = switch (_filter) {
        WorkFilter.all => true,
        WorkFilter.inProgress => work.status == WorkStatus.inProgress,
        WorkFilter.completed => work.status == WorkStatus.completed,
        WorkFilter.pending => work.status == WorkStatus.pending,
      };
      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFE),
      appBar: AppBar(
        toolbarHeight: 76,
        automaticallyImplyLeading: true,
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        title: const Text(
          'Control Fotográfico de Obras',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (widget.session != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Text(
                  widget.session!.roleLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: 'Notificaciones',
                onPressed: () => _showNotifications(context),
                icon: const Icon(Icons.notifications_none_rounded, size: 30),
              ),
              Positioned(
                right: 4,
                top: 5,
                child: Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ConnectivityBanner(
        child: SafeArea(
          top: false,
          child: FutureBuilder<List<Work>>(
            future: _worksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _MessageState(
                  icon: Icons.cloud_off_rounded,
                  title: 'No pudimos cargar tus obras',
                  message: 'Inténtalo nuevamente en unos momentos.',
                  actionLabel: 'Reintentar',
                  onAction: _retry,
                );
              }

              final works = _filtered(snapshot.data ?? const []);
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _Header(searchController: _searchController),
                  ),
                  SliverToBoxAdapter(
                    child: _FilterBar(
                      selected: _filter,
                      onSelected: (filter) => setState(() => _filter = filter),
                    ),
                  ),
                  if (works.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _MessageState(
                        icon: Icons.search_off_rounded,
                        title: 'No encontramos obras',
                        message: 'Prueba con otra búsqueda o filtro.',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                      sliver: SliverList.separated(
                        itemCount: works.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) => _WorkCard(
                          work: works[index],
                          session: widget.session,
                          photoRepository:
                              widget.photoRepository ??
                              LocalPhotoRepository.instance,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: widget.session == null
          ? null
          : NavigationBar(
              selectedIndex: 1,
              onDestinationSelected: (index) {
                final profileIndex = _destinations.length - 1;
                if (index == 0) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                } else if (index == profileIndex) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ProfileScreen(
                        session: widget.session!,
                        onLogout: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          widget.onLogout?.call();
                        },
                      ),
                    ),
                  );
                }
              },
              destinations: _destinations,
            ),
    );
  }

  List<NavigationDestination> get _destinations => [
    const NavigationDestination(
      icon: Icon(Icons.home_outlined),
      label: 'Inicio',
    ),
    const NavigationDestination(
      icon: Icon(Icons.apartment_rounded),
      label: 'Obras',
    ),
    const NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      label: 'Perfil',
    ),
  ];

  void _showNotifications(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => const SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notificaciones',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('3 avisos pendientes'),
              subtitle: Text(
                'El detalle se habilitará al conectar el backend.',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mis obras',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          TextField(
            key: const Key('worksSearchField'),
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por obra o beneficiario',
              prefixIcon: const Icon(Icons.search_rounded, size: 30),
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: searchController.clear,
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});

  final WorkFilter selected;
  final ValueChanged<WorkFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    const labels = {
      WorkFilter.all: 'Todas',
      WorkFilter.inProgress: 'En proceso',
      WorkFilter.completed: 'Terminadas',
      WorkFilter.pending: 'Pendientes',
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: Row(
        children: labels.entries.map((entry) {
          final active = entry.key == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              key: Key('filter-${entry.key.name}'),
              selected: active,
              onSelected: (_) => onSelected(entry.key),
              showCheckmark: false,
              label: Text(entry.value),
              labelStyle: TextStyle(
                color: active ? Colors.white : AppColors.muted,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
              selectedColor: AppColors.blue,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: active ? AppColors.blue : AppColors.border,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _WorkCard extends StatelessWidget {
  const _WorkCard({
    required this.work,
    required this.photoRepository,
    required this.session,
  });

  final Work work;
  final PhotoRepository photoRepository;
  final UserSession? session;

  Color get color => switch (work.status) {
    WorkStatus.inProgress => AppColors.blue,
    WorkStatus.completed => AppColors.success,
    WorkStatus.pending => AppColors.warning,
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: const Color(0x1F183763),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        key: Key('work-${work.id}'),
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => WorkDetailScreen(
                work: work,
                photoRepository: photoRepository,
                allowCapture: session?.can(Permission.captureEvidence) ?? true,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.11),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.apartment_rounded,
                      color: color,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          work.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 18,
                          runSpacing: 12,
                          children: [
                            _Detail(
                              icon: Icons.person_outline_rounded,
                              label: 'Beneficiario',
                              value: work.beneficiary,
                            ),
                            _Detail(
                              icon: Icons.location_on_outlined,
                              label: 'Municipio',
                              value: work.municipality,
                            ),
                            _Detail(
                              icon: Icons.outlined_flag_rounded,
                              label: 'Etapa',
                              value: work.stage,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_vert_rounded, color: AppColors.muted),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Progreso de evidencias',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  const Spacer(),
                  Text(
                    '${work.completedEvidence} / ${work.totalEvidence}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: work.progress,
                        minHeight: 8,
                        color: color,
                        backgroundColor: const Color(0xFFE5E9F1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${work.progressPercent}%',
                    style: TextStyle(color: color, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      work.status == WorkStatus.completed
                          ? Icons.check_circle_outline_rounded
                          : Icons.assignment_outlined,
                      color: color,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        work.status == WorkStatus.completed
                            ? 'Completa'
                            : '${work.pendingEvidence} ${work.pendingEvidence == 1 ? 'evidencia pendiente' : 'evidencias pendientes'}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.muted,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: AppColors.muted),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 58, color: AppColors.muted),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 7),
            Text(message, textAlign: TextAlign.center),
            if (onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel ?? 'Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
