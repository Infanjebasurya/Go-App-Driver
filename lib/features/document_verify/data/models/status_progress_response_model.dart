class ProgressStepItemModel {
  const ProgressStepItemModel({
    required this.code,
    required this.label,
    required this.completed,
    this.order,
    this.status,
  });

  final String code;
  final String label;
  final bool completed;
  final int? order;
  final String? status;

  factory ProgressStepItemModel.fromJson(Map<String, dynamic> json) {
    return ProgressStepItemModel(
      code: (json['code'] ?? json['step_code'] ?? json['id'] ?? '').toString(),
      label: (json['label'] ?? json['title'] ?? '').toString(),
      completed: _parseBool(json['completed'] ?? json['is_completed']) ?? false,
      order: _toInt(json['order'] ?? json['sequence']),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'code': code,
      'label': label,
      'completed': completed,
      if (order != null) 'order': order,
      if (status != null) 'status': status,
    };
  }

  static bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == 'success') return true;
      if (normalized == 'false' || normalized == 'failed') return false;
    }
    return null;
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class StatusProgressResponseModel {
  const StatusProgressResponseModel({
    required this.steps,
    this.completedCount,
    this.totalCount,
    this.progressPercent,
    this.overallStatus,
    this.message,
    this.success,
  });

  final List<ProgressStepItemModel> steps;
  final int? completedCount;
  final int? totalCount;
  final int? progressPercent;
  final String? overallStatus;
  final String? message;
  final bool? success;

  factory StatusProgressResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic stepsRaw =
        json['steps'] ?? json['documents'] ?? json['data'] ?? const <dynamic>[];
    final parsedSteps = (stepsRaw is List<dynamic> ? stepsRaw : const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(ProgressStepItemModel.fromJson)
        .toList(growable: false);

    final int? total = _toInt(json['total_count'] ?? json['totalCount']);
    final int? done = _toInt(json['completed_count'] ?? json['completedCount']);

    return StatusProgressResponseModel(
      steps: parsedSteps,
      completedCount: done ?? parsedSteps.where((e) => e.completed).length,
      totalCount: total ?? parsedSteps.length,
      progressPercent: _toInt(json['progress_percent'] ?? json['progressPercent']),
      overallStatus: (json['overall_status'] ?? json['overallStatus'])
          ?.toString(),
      message: json['message']?.toString(),
      success: _parseBool(json['success'] ?? json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'steps': steps.map((e) => e.toJson()).toList(growable: false),
      if (completedCount != null) 'completed_count': completedCount,
      if (totalCount != null) 'total_count': totalCount,
      if (progressPercent != null) 'progress_percent': progressPercent,
      if (overallStatus != null) 'overall_status': overallStatus,
      if (message != null) 'message': message,
      if (success != null) 'success': success,
    };
  }

  static bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == 'success') return true;
      if (normalized == 'false' || normalized == 'failed') return false;
    }
    return null;
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

