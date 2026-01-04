import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:taskmanagementsouradip/data/local/hive_checkin_repository.dart';
import 'package:taskmanagementsouradip/data/local/adapters/checkin_adapter.dart';
import 'package:taskmanagementsouradip/domains/enums/enums.dart';

void main() {
  setUp(() async {
    final dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    Hive.registerAdapter(CheckinAdapter());
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
  });

  test('create checkin stores pending checkin', () async {
    final repo = HiveCheckinRepository();
    final checkin = await repo.createCheckin(
      taskId: 't1',
      notes: 'This is a test checkin',
      category: CheckInCategory.safety,
      lat: 1.0,
      lng: 2.0,
    );
    expect(checkin.syncStatus, SyncStatus.pending);
    final pending = await repo.getPending();
    expect(pending.length, 1);
    expect(pending.first.id, checkin.id);
  });
}
