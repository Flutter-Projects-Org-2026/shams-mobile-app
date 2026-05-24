/// MaintenanceRequestModel — نموذج طلب الصيانة
///
/// Represents a structured solar maintenance/installation request submitted
/// by a client to a workshop. Used in [WorkshopProfile] and [ChatProvider].
class MaintenanceRequestModel {
  /// Unique request identifier (timestamp-based for local state)
  final String id;

  /// ID of the target workshop
  final String workshopId;

  /// ID of the requesting client
  final String clientId;

  /// Primary service type requested
  final String serviceType;

  /// Solar system capacity in kilowatts (e.g. 5.0)
  final double? systemCapacityKw;

  /// Brand of the inverter (e.g. Growatt, Huawei SUN2000)
  final String? inverterBrand;

  /// Type of battery in the system
  final String? batteryType;

  /// Free-text description of the problem or request
  final String problemDescription;

  /// When the request was submitted
  final DateTime requestedAt;

  /// Current status of the request
  final MaintenanceRequestStatus status;

  const MaintenanceRequestModel({
    required this.id,
    required this.workshopId,
    required this.clientId,
    required this.serviceType,
    this.systemCapacityKw,
    this.inverterBrand,
    this.batteryType,
    required this.problemDescription,
    required this.requestedAt,
    this.status = MaintenanceRequestStatus.pending,
  });

  /// Returns a human-readable summary for use as the initial chat message.
  String toRequestSummary() {
    final buffer = StringBuffer('📋 طلب خدمة جديد\n');
    buffer.writeln('نوع الخدمة: $serviceType');
    if (systemCapacityKw != null) {
      buffer.writeln('قدرة المنظومة: $systemCapacityKw كيلوواط');
    }
    if (inverterBrand != null && inverterBrand!.isNotEmpty) {
      buffer.writeln('نوع العاكس: $inverterBrand');
    }
    if (batteryType != null && batteryType!.isNotEmpty) {
      buffer.writeln('نوع البطارية: $batteryType');
    }
    buffer.write('تفاصيل المشكلة: $problemDescription');
    return buffer.toString();
  }

  MaintenanceRequestModel copyWith({
    String? id,
    String? workshopId,
    String? clientId,
    String? serviceType,
    double? systemCapacityKw,
    String? inverterBrand,
    String? batteryType,
    String? problemDescription,
    DateTime? requestedAt,
    MaintenanceRequestStatus? status,
  }) {
    return MaintenanceRequestModel(
      id: id ?? this.id,
      workshopId: workshopId ?? this.workshopId,
      clientId: clientId ?? this.clientId,
      serviceType: serviceType ?? this.serviceType,
      systemCapacityKw: systemCapacityKw ?? this.systemCapacityKw,
      inverterBrand: inverterBrand ?? this.inverterBrand,
      batteryType: batteryType ?? this.batteryType,
      problemDescription: problemDescription ?? this.problemDescription,
      requestedAt: requestedAt ?? this.requestedAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workshop_id': workshopId,
      'client_id': clientId,
      'service_type': serviceType,
      'system_capacity_kw': systemCapacityKw,
      'inverter_brand': inverterBrand,
      'battery_type': batteryType,
      'problem_description': problemDescription,
      'requested_at': requestedAt.toIso8601String(),
      'status': status == MaintenanceRequestStatus.inProgress ? 'in_progress' : status.name,
    };
  }

  factory MaintenanceRequestModel.fromMap(Map<String, dynamic> map) {
    String dbStatus = map['status'] ?? '';
    if (dbStatus == 'in_progress') dbStatus = 'inProgress';
    
    return MaintenanceRequestModel(
      id: map['id'] ?? '',
      workshopId: map['workshop_id'] ?? '',
      clientId: map['client_id'] ?? '',
      serviceType: map['service_type'] ?? '',
      systemCapacityKw: (map['system_capacity_kw'] as num?)?.toDouble(),
      inverterBrand: map['inverter_brand'],
      batteryType: map['battery_type'],
      problemDescription: map['problem_description'] ?? '',
      requestedAt: map['requested_at'] != null
          ? DateTime.parse(map['requested_at'])
          : DateTime.now(),
      status: MaintenanceRequestStatus.values.firstWhere(
        (e) => e.name == dbStatus,
        orElse: () => MaintenanceRequestStatus.pending,
      ),
    );
  }
}

/// Status lifecycle for a maintenance request.
enum MaintenanceRequestStatus {
  /// Submitted but not yet reviewed by the workshop
  pending,

  /// Workshop has accepted the request
  accepted,

  /// Technician is on-site or actively working
  inProgress,

  /// Service completed
  completed,

  /// Request was rejected or cancelled
  cancelled,
}

/// Arabic labels for [MaintenanceRequestStatus].
extension MaintenanceRequestStatusLabel on MaintenanceRequestStatus {
  String get label {
    switch (this) {
      case MaintenanceRequestStatus.pending:
        return 'قيد الانتظار';
      case MaintenanceRequestStatus.accepted:
        return 'مقبول';
      case MaintenanceRequestStatus.inProgress:
        return 'جارٍ التنفيذ';
      case MaintenanceRequestStatus.completed:
        return 'مكتمل';
      case MaintenanceRequestStatus.cancelled:
        return 'ملغي';
    }
  }
}
