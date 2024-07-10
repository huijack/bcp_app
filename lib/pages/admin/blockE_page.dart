import 'package:flutter/material.dart';

import '../../components/my_building.dart';

class BlockEPage extends StatelessWidget {
  const BlockEPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyBuilding(
      buildingName: 'Block E',
      equipmentOrder: [
        'Projector',
        'Air Conditioner',
        'Fan',
        'Light',
        'Door',
        'Others',
      ],
    );
  }
}