import 'package:equatable/equatable.dart';

class MailEventModel extends Equatable {
  const MailEventModel({required this.id, required this.category, this.company, this.role, this.summary, this.subject, this.receivedAt, this.confidence = 0, this.status = 'new', this.jobTitle, this.suggestedStage});
  final int id;
  final String category, status;
  final String? company, role, summary, subject, receivedAt, jobTitle, suggestedStage;
  final double confidence;

  factory MailEventModel.fromJson(Map<String, dynamic> j) => MailEventModel(
        id: j['id'] as int,
        category: j['category'] as String? ?? 'recruiter_outreach',
        company: j['company'] as String?,
        role: j['role'] as String?,
        summary: j['summary'] as String?,
        subject: j['subject'] as String?,
        receivedAt: j['received_at'] as String?,
        confidence: (j['confidence'] as num?)?.toDouble() ?? 0,
        status: j['status'] as String? ?? 'new',
        jobTitle: (j['job'] as Map?)?['title'] as String?,
        suggestedStage: j['suggested_stage'] as String?,
      );

  @override
  List<Object?> get props => [id, category, status, company, role];
}

class MailAccountModel extends Equatable {
  const MailAccountModel({required this.id, required this.username, this.lastSyncAt, this.lastError});
  final int id;
  final String username;
  final String? lastSyncAt, lastError;
  factory MailAccountModel.fromJson(Map<String, dynamic> j) => MailAccountModel(id: j['id'] as int, username: j['username'] as String? ?? '', lastSyncAt: j['last_sync_at'] as String?, lastError: j['last_error'] as String?);
  @override
  List<Object?> get props => [id, username, lastSyncAt, lastError];
}
