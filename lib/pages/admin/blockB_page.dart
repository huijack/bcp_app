import 'package:flutter/material.dart';

import '../../components/my_building.dart';

class BlockBPage extends StatelessWidget {
  const BlockBPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyBuilding(
      buildingName: 'Block B',
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