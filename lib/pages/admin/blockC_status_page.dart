import 'package:flutter/material.dart';

import '../../components/my_building.dart';

class BlockCStatusPage extends StatelessWidget {
  final String status;

  const BlockCStatusPage({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return MyBuilding(
      buildingName: 'Block C',
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