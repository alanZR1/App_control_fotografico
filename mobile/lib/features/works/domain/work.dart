enum WorkStatus { inProgress, completed, pending }

enum StageStatus { completed, inProgress, pending, locked }

enum RequirementStatus { missing, pending, synchronized, approved, rejected }

class PhotoRequirement {
  const PhotoRequirement({
    required this.typeId,
    required this.name,
    required this.required,
    required this.status,
  });

  final int typeId;
  final String name;
  final bool required;
  final RequirementStatus status;
}

class WorkStage {
  WorkStage({
    required this.number,
    required this.name,
    required this.completed,
    required this.total,
    required this.status,
    required this.photoTypes,
  }) : requirements = List.generate(
         photoTypes.length,
         (index) => PhotoRequirement(
           typeId: number * 100 + index + 1,
           name: photoTypes[index],
           required: true,
           status: index < completed
               ? RequirementStatus.synchronized
               : RequirementStatus.missing,
         ),
       );

  final int number;
  final String name;
  final int completed;
  final int total;
  final StageStatus status;
  final List<String> photoTypes;
  final List<PhotoRequirement> requirements;
}

class Work {
  const Work({
    required this.id,
    required this.title,
    required this.beneficiary,
    required this.municipality,
    required this.stage,
    required this.completedEvidence,
    required this.totalEvidence,
    required this.pendingEvidence,
    required this.status,
    required this.company,
    required this.address,
    required this.stages,
  });

  final int id;
  final String title;
  final String beneficiary;
  final String municipality;
  final String stage;
  final int completedEvidence;
  final int totalEvidence;
  final int pendingEvidence;
  final WorkStatus status;
  final String company;
  final String address;
  final List<WorkStage> stages;

  String get folio => 'OB-${id.toString().padLeft(5, '0')}';

  double get progress =>
      totalEvidence == 0 ? 0 : completedEvidence / totalEvidence;
  int get progressPercent => (progress * 100).round();
}
