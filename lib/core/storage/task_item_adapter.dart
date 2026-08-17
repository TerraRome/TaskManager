import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/schedule/domain/models/task_item.dart';

/// typeId 0 — TaskItem
class TaskItemAdapter extends TypeAdapter<TaskItem> {
  @override
  final int typeId = 0;

  @override
  TaskItem read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final description = reader.readBool() ? reader.readString() : null;
    final timeRange = reader.readString();
    final hasStartTime = reader.readBool();
    final startTime =
        hasStartTime ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null;
    final hasEndTime = reader.readBool();
    final endTime =
        hasEndTime ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null;
    final colorValue = reader.readInt();
    final membersLen = reader.readInt();
    final members = List<String>.generate(membersLen, (_) => reader.readString());
    final tagsLen = reader.readInt();
    final tags = List<String>.generate(tagsLen, (_) => reader.readString());
    final isDone = reader.readBool();
    final projectId = reader.readBool() ? reader.readString() : null;

    return TaskItem(
      id: id,
      title: title,
      description: description,
      timeRange: timeRange,
      startTime: startTime,
      endTime: endTime,
      color: Color(colorValue),
      members: members,
      tags: tags,
      isDone: isDone,
      projectId: projectId,
    );
  }

  @override
  void write(BinaryWriter writer, TaskItem obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeBool(obj.description != null);
    if (obj.description != null) writer.writeString(obj.description!);
    writer.writeString(obj.timeRange);
    writer.writeBool(obj.startTime != null);
    if (obj.startTime != null) {
      writer.writeInt(obj.startTime!.millisecondsSinceEpoch);
    }
    writer.writeBool(obj.endTime != null);
    if (obj.endTime != null) {
      writer.writeInt(obj.endTime!.millisecondsSinceEpoch);
    }
    writer.writeInt(obj.color.toARGB32());
    writer.writeInt(obj.members.length);
    for (final m in obj.members) {
      writer.writeString(m);
    }
    writer.writeInt(obj.tags.length);
    for (final t in obj.tags) {
      writer.writeString(t);
    }
    writer.writeBool(obj.isDone);
    writer.writeBool(obj.projectId != null);
    if (obj.projectId != null) writer.writeString(obj.projectId!);
  }
}
