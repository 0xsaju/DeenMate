import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstract interface for network information
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Future<ConnectivityResult> get connectionType;
}

/// Implementation of NetworkInfo using connectivity_plus package
class NetworkInfoImpl implements NetworkInfo {
  
  NetworkInfoImpl(this._connectivity);
  final Connectivity _connectivity;
  
  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result.any((connection) => 
      connection == ConnectivityResult.mobile || 
      connection == ConnectivityResult.wifi ||
      connection == ConnectivityResult.ethernet,
    );
  }
  
  @override
  Future<ConnectivityResult> get connectionType async {
    final result = await _connectivity.checkConnectivity();
    return result.first;
  }
}
