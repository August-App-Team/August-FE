import 'package:august/get_api/onboard/get_department.dart';
import 'package:flutter/foundation.dart';

class DepartmentProvider with ChangeNotifier {
  List<String> _departmentList = [];

  List<String> get departmentList => _departmentList;

  DepartmentProvider() {
    loadDepartments();
  }

  Future<void> loadDepartments() async {
    try {
      List<String> loadedDepartments = await fetchDepartments();
      if (loadedDepartments.isNotEmpty) {
        _departmentList =
            ["ID: null, Undecided (UNDECIDED) "] + loadedDepartments;
        notifyListeners();
      } else {
        // Optionally handle the case where loaded data is empty but successful
        print("No departments found, but fetched successfully.");
      }
    } catch (e) {
      // Handle errors in fetching data
      print('Failed to load departments: $e');
      // Optionally you can maintain the old list if new one fails to load
    }
  }
}
