import 'package:get/get.dart';
import 'package:heratmap/core/data_state.dart';
import 'package:heratmap/data/models/emergency_contact_model.dart';
import 'package:heratmap/data/repository/emergency_contact_repository.dart';

class EmergencyContactController extends GetxController with DataStateMixin {
  final EmergencyContactRepository _repo;
  EmergencyContactController(this._repo);

  final contacts = <EmergencyContactModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadContacts();
  }

  Future<void> loadContacts({bool forceRefresh = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    dataError.value = null;

    final result = await _repo.getContacts(forceRefresh: forceRefresh);
    final data = result.dataOrNull;
    if (data != null) contacts.value = data;
    applyResult(result);
    isLoading.value = false;
  }

  Future<void> reload() => loadContacts(forceRefresh: true);
}
