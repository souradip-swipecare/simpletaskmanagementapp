part of 'checkin_form_cubit.dart';

@immutable
class CheckinFormState {
  final bool loading;
  final bool success;
  final String? error;
  final String? id;

  const CheckinFormState({
    this.loading = false,
    this.success = false,
    this.error,
    this.id,
  });

  factory CheckinFormState.initial() => const CheckinFormState();
  factory CheckinFormState.loading() => const CheckinFormState(loading: true);
  factory CheckinFormState.success(String id) =>
      CheckinFormState(success: true, id: id);
  factory CheckinFormState.error(String message) =>
      CheckinFormState(error: message);
  factory CheckinFormState.invalid(String message) =>
      CheckinFormState(error: message);
}
