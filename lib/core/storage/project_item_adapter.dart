import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/projects/domain/models/project_item.dart';

/// typeId 1 — ProjectItem
class ProjectItemAdapter extends TypeAdapter<ProjectItem> {
  @override
  final int typeId = 1;

  @override
  ProjectItem read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final description = reader.readString();
    final colorValue = reader.readInt();
    final totalTasks = reader.readInt();
    final completedTasks = reader.readInt();
    final membersLen = reader.readInt();
    final members =
        List<String>.generate(membersLen, (_) => reader.readString());
    final deadline =
        DateTime.fromMillisecondsSinceEpoch(reader.readInt());

    return ProjectItem(
      id: id,
      title: title,
      description: description,
      color: Color(colorValue),
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      members: members,
      deadline: deadline,
    );
  }

  @override
  void write(BinaryWriter writer, ProjectItem obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeInt(obj.color.toARGB32());
    writer.writeInt(obj.totalTasks);
    writer.writeInt(obj.completedTasks);
    writer.writeInt(obj.members.length);
    for (final m in obj.members) {
      writer.writeString(m);
    }
    writer.writeInt(obj.deadline.millisecondsSinceEpoch);
  }
}
