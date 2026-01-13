part of '../index.dart';

class CRMTask extends KanbanTask {
  final String title;
  final String? serviceType;
  final String? address;
  final String? timeAgo;
  final String? statusMessage;
  final String? source;
  final String? phone;
  final List<String> crmTags;

  CRMTask({
    required this.title,
    this.serviceType,
    this.address,
    this.timeAgo,
    this.statusMessage,
    this.source,
    this.phone,
    this.crmTags = const [],
    String? id,
  }) : super(id: id ?? const Uuid().v4());

  CRMTask copyWith({
    String? id,
    String? title,
    String? serviceType,
    String? address,
    String? timeAgo,
    String? statusMessage,
    String? source,
    String? phone,
    List<String>? crmTags,
  }) {
    return CRMTask(
      id: id ?? this.id,
      title: title ?? this.title,
      serviceType: serviceType ?? this.serviceType,
      address: address ?? this.address,
      timeAgo: timeAgo ?? this.timeAgo,
      statusMessage: statusMessage ?? this.statusMessage,
      source: source ?? this.source,
      phone: phone ?? this.phone,
      crmTags: crmTags ?? this.crmTags,
    );
  }
}
