import 'package:url_launcher/url_launcher.dart';

abstract interface class EmergencyCallService {
  Future<bool> call(String number);
}

class DeviceEmergencyCallService implements EmergencyCallService {
  @override
  Future<bool> call(String number) => launchUrl(
    Uri(scheme: 'tel', path: number),
    mode: LaunchMode.externalApplication,
  );
}
