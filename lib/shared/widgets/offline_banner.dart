import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/connectivity_provider.dart';
import '../../core/theme/app_text_styles.dart';

/// Thin banner shown at the top of a screen's body whenever the app is
/// offline, signalling that the list below is being served from cache.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityCubit>().state;
    if (isOnline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: const Color(0xFFF59E0B),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            "You're offline — showing saved data",
            style: AppTextStyles.caption(color: Colors.white)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
