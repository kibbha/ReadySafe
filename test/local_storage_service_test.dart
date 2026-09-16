import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('malformed family data falls back safely', () async {
    SharedPreferences.setMockInitialValues({'family': '{broken'});
    expect(await LocalStorageService().family(), {
      'adults': 1,
      'children': 0,
      'care': 0,
      'pets': 0,
    });
  });
}
