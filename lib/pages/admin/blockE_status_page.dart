import 'package:flutter/material.dart';

import '../../components/my_building.dart';

class BlockEStatusPage extends StatelessWidget {
  final String status;

  const BlockEStatusPage({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return MyBuilding(
      buildingName: 'Block E',
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
