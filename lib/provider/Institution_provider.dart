import 'package:august/get_api/onboard/get_univ.dart';
import 'package:flutter/foundation.dart';

class InstitutionProvider with ChangeNotifier {
  List<Institution> _institutionList = [];

  List<Institution> get institutionList => _institutionList;

  InstitutionProvider() {
    loadInstitution();
  }

  set institutionList(List<Institution> value) {
    _institutionList = value;
    notifyListeners();
  }

  Future<void> loadInstitution() async {
    _institutionList = await fetchInstitutions();
    notifyListeners();
  }
}
