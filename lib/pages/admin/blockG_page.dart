import 'package:flutter/material.dart';

import '../../components/my_building.dart';

class BlockGPage extends StatelessWidget {
  const BlockGPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyBuilding(
      buildingName: 'Block G',
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