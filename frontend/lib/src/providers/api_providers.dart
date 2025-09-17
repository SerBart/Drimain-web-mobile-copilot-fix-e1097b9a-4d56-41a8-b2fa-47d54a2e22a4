import 'package:provider/provider.dart';
import '../providers/auth_state_notifier.dart';
import '../services/api_client.dart';

class ApiProviders {
  static final ApiClient _apiClient = ApiClient();
  
  static List<ChangeNotifierProvider> get providers => [
    ChangeNotifierProvider<AuthStateNotifier>(
      create: (context) => AuthStateNotifier(),
    ),
    // TODO: Add other providers as needed
    // ChangeNotifierProvider<ZgloszenieProvider>(create: (context) => ZgloszenieProvider(_apiClient)),
    // ChangeNotifierProvider<HarmonogramProvider>(create: (context) => HarmonogramProvider(_apiClient)),
    // ChangeNotifierProvider<PartProvider>(create: (context) => PartProvider(_apiClient)),
  ];
  
  static ApiClient get apiClient => _apiClient;
}