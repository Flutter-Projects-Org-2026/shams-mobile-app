import 'package:supabase_flutter/supabase_flutter.dart';

class MaintenanceService {
  static final _db = Supabase.instance.client;

  // ── CREATE ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> createRequest({
    required String workshopId,
    required String serviceType,
    required String problemDescription,
    double? systemCapacityKw,
    String? inverterBrand,
    String? batteryType,
  }) async {
    final userId = _db.auth.currentUser!.id;

    final request = await _db.from('maintenance_requests').insert({
      'workshop_id': workshopId,
      'client_id': userId,
      'service_type': serviceType,
      'problem_description': problemDescription,
      'system_capacity_kw': systemCapacityKw,
      'inverter_brand': inverterBrand,
      'battery_type': batteryType,
      'status': 'pending',
    }).select().single();

    // Trigger notification asynchronously
    _createMaintenanceNotification(
      requestId: request['id'] as String,
      workshopId: workshopId,
      clientId: userId,
      serviceType: serviceType,
    );

    return request;
  }

  static void _createMaintenanceNotification({
    required String requestId,
    required String workshopId,
    required String clientId,
    required String serviceType,
  }) async {
    try {
      // Find the workshop owner
      final workshop = await _db
          .from('workshops')
          .select('owner_id')
          .eq('id', workshopId)
          .single();
      final ownerId = workshop['owner_id'] as String;

      // Fetch client's name
      final clientProfile = await _db
          .from('profiles')
          .select('name')
          .eq('id', clientId)
          .maybeSingle();
      final clientName = clientProfile?['name'] ?? 'عميل شمس';

      await _db.from('notifications').insert({
        'user_id': ownerId,
        'title': 'طلب صيانة جديد',
        'message': 'تلقيت طلب صيانة جديد من $clientName ($serviceType)',
        'type': 'maintenance_status',
        'target_id': requestId,
      });
    } catch (e) {
      print('Error creating maintenance request notification: $e');
    }
  }

  // ── READ (Client's requests) ────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> fetchMyRequests() async {
    final userId = _db.auth.currentUser!.id;
    return await _db
        .from('maintenance_requests')
        .select('''
          *,
          workshops!maintenance_requests_workshop_id_fkey(id, name, logo_url, city)
        ''')
        .eq('client_id', userId)
        .order('requested_at', ascending: false);
  }

  // ── READ (Workshop's received requests) ─────────────────────────────────

  static Future<List<Map<String, dynamic>>> fetchWorkshopRequests(
    String workshopId,
  ) async {
    return await _db
        .from('maintenance_requests')
        .select('''
          *,
          profiles!maintenance_requests_client_id_fkey(id, name, phone, profile_image_url)
        ''')
        .eq('workshop_id', workshopId)
        .order('requested_at', ascending: false);
  }

  // ── UPDATE STATUS (Workshop owner) ──────────────────────────────────────

  static Future<void> updateStatus({
    required String requestId,
    required String newStatus,
  }) async {
    await _db.from('maintenance_requests').update({
      'status': newStatus,
    }).eq('id', requestId);

    // Trigger status update notification asynchronously
    _createStatusUpdateNotification(requestId: requestId, newStatus: newStatus);
  }

  static void _createStatusUpdateNotification({
    required String requestId,
    required String newStatus,
  }) async {
    try {
      // Fetch request details
      final request = await _db
          .from('maintenance_requests')
          .select('client_id, workshop_id, service_type')
          .eq('id', requestId)
          .single();
      
      final clientId = request['client_id'] as String;
      final workshopId = request['workshop_id'] as String;
      final serviceType = request['service_type'] as String;

      // Fetch workshop name
      final workshop = await _db
          .from('workshops')
          .select('name')
          .eq('id', workshopId)
          .single();
      final workshopName = workshop['name'] as String;

      String statusStr = 'قيد الانتظار';
      if (newStatus == 'accepted') statusStr = 'مقبول';
      if (newStatus == 'rejected') statusStr = 'مرفوض';
      if (newStatus == 'completed') statusStr = 'مكتمل';

      await _db.from('notifications').insert({
        'user_id': clientId,
        'title': 'تحديث طلب الصيانة',
        'message': 'تم تحديث حالة طلب الصيانة ($serviceType) لدى $workshopName إلى: $statusStr',
        'type': 'maintenance_status',
        'target_id': requestId,
      });
    } catch (e) {
      print('Error creating maintenance status update notification: $e');
    }
  }

  // ── DELETE ──────────────────────────────────────────────────────────────

  static Future<void> deleteRequest(String requestId) async {
    await _db.from('maintenance_requests').delete().eq('id', requestId);
  }
}
