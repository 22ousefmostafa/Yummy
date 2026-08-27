import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'network_info.dart';

/// App-wide online/offline signal. A single instance is shared across every
/// screen (registered as a lazy singleton) so the offline banner reflects
/// one source of truth instead of each screen polling independently.
class ConnectivityCubit extends Cubit<bool> {
  final NetworkInfo networkInfo;
  StreamSubscription<bool>? _subscription;

  ConnectivityCubit(this.networkInfo) : super(true) {
    networkInfo.isConnected.then(emit);
    _subscription = networkInfo.onConnectivityChanged.listen(emit);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
