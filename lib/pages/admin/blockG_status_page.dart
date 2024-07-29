import 'package:flutter/material.dart';

import '../../components/my_building.dart';

class BlockGStatusPage extends StatelessWidget {
  final String status;

  const BlockGStatusPage({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return MyBuilding(
      buildingName: 'Block G',
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