import 'package:flutter/material.dart';

import '../../components/my_building.dart';

class BlockAStatusPage extends StatelessWidget {
  final String status;

  const BlockAStatusPage({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return MyBuilding(
      buildingName: 'Block A',
      equipmentOrder: const [
        'Projector',
        'Air Conditioner',
        'Fan',
        'Light',
        'Door',
        'Others',
      ],
      status: status,
    );
  }
}
