import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:taskmanagementsouradip/viewmodel/checkin_form_cubit.dart';
import 'package:taskmanagementsouradip/data/local/hive_checkin_repository.dart';
import 'package:taskmanagementsouradip/data/sync/checkin_sync_service.dart';
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

  test('form validation fails for short notes', () async {
    final cubit = CheckinFormCubit(
      HiveCheckinRepository(),
      CheckinSyncService(),
    );
    cubit.submit(
      taskId: 't1',
      notes: 'short',
      category: CheckInCategory.safety,
      lat: 1.0,
      lng: 2.0,
    );
    await Future.delayed(const Duration(milliseconds: 100));
    final state = cubit.state;
    expect(state.error, 'Notes must be at least 10 characters');
  });
}
