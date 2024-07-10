import 'package:flutter/material.dart';

import '../../components/my_building.dart';

class BlockCPage extends StatelessWidget {
  const BlockCPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyBuilding(
      buildingName: 'Block C',
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