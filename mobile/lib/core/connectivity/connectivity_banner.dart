import 'package:flutter/material.dart';

import 'connectivity_service.dart';

class ConnectivityBanner extends StatelessWidget {
  ConnectivityBanner({
    required this.child,
    ConnectivityService? service,
    super.key,
  }) : service = service ?? DeviceConnectivityService();

  final Widget child;
  final ConnectivityService service;

  @override
  Widget build(BuildContext context) => StreamBuilder<bool>(
    stream: service.onlineChanges,
    initialData: true,
    builder: (context, snapshot) => Column(
      children: [
        if (snapshot.data == false)
          Container(
            key: const Key('offlineBanner'),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
            color: const Color(0xFFFFE6C7),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  size: 18,
                  color: Color(0xFF9A4A00),
                ),
                SizedBox(width: 7),
                Text(
                  'Sin conexión · las evidencias se guardarán localmente',
                  style: TextStyle(
                    color: Color(0xFF7A3B00),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        Expanded(child: child),
      ],
    ),
  );
}
