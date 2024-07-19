import 'package:flutter/material.dart';

import '../../components/my_building.dart';

class BlockBStatusPage extends StatelessWidget {
  final String status;

  const BlockBStatusPage({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return MyBuilding(
      buildingName: 'Block B',
      equipmentOrder: [
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
