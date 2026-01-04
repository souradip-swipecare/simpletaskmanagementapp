import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domains/enums/enums.dart';
import '../../viewmodel/checkin_form_cubit.dart';
import '../../data/local/hive_checkin_repository.dart';
import '../../data/sync/checkin_sync_service.dart';
import 'package:geolocator/geolocator.dart';

class CheckinFormScreen extends StatefulWidget {
  final String taskId;
  const CheckinFormScreen({super.key, required this.taskId});

  @override
  State<CheckinFormScreen> createState() => _CheckinFormScreenState();
}

class _CheckinFormScreenState extends State<CheckinFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesCtrl = TextEditingController();
  CheckInCategory _category = CheckInCategory.safety;
  double? _lat;
  double? _lng;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final asked = await Geolocator.requestPermission();
      if (asked == LocationPermission.denied) return;
    }
    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _lat = pos.latitude;
      _lng = pos.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CheckinFormCubit(HiveCheckinRepository(), CheckinSyncService()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Create Check-in')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _notesCtrl,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  validator: (v) {
                    if (v == null || v.trim().length < 10)
                      return 'Notes must be at least 10 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<CheckInCategory>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: CheckInCategory.values
                      .map(
                        (c) => DropdownMenuItem(value: c, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _category = v);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _captureLocation,
                      child: const Text('Capture Location'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _lat == null
                            ? 'No location'
                            : 'Lat: \\${_lat!.toStringAsFixed(4)}, Lng: \\${_lng!.toStringAsFixed(4)}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                BlocConsumer<CheckinFormCubit, CheckinFormState>(
                  listener: (context, state) {
                    if (state.success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Check-in saved')),
                      );
                      Navigator.of(context).pop();
                    }
                    if (state.error != null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.error!)));
                    }
                  },
                  builder: (context, state) {
                    if (state.loading) return const CircularProgressIndicator();
                    return ElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        if (_lat == null || _lng == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Location is required'),
                            ),
                          );
                          return;
                        }
                        context.read<CheckinFormCubit>().submit(
                          taskId: widget.taskId,
                          notes: _notesCtrl.text,
                          category: _category,
                          lat: _lat!,
                          lng: _lng!,
                        );
                      },
                      child: const Text('Submit'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
