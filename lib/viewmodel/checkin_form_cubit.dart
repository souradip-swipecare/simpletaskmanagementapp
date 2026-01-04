import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../data/local/hive_checkin_repository.dart';
import '../data/sync/checkin_sync_service.dart';
import '../domains/enums/enums.dart';

part 'checkin_form_state.dart';

class CheckinFormCubit extends Cubit<CheckinFormState> {
  final HiveCheckinRepository _repo;
  final CheckinSyncService _sync;

  CheckinFormCubit(this._repo, this._sync) : super(CheckinFormState.initial());

  void submit({
    required String taskId,
    required String notes,
    required CheckInCategory category,
    required double lat,
    required double lng,
  }) async {
    if (notes.trim().length < 10) {
      emit(CheckinFormState.invalid('Notes must be at least 10 characters'));
      return;
    }

    emit(CheckinFormState.loading());
    try {
      final checkin = await _repo.createCheckin(
        taskId: taskId,
        notes: notes.trim(),
        category: category,
        lat: lat,
        lng: lng,
      );
      // Try to sync immediately
      await _sync.syncPending();
      emit(CheckinFormState.success(checkin.id));
    } catch (e) {
      emit(CheckinFormState.error(e.toString()));
    }
  }
}
