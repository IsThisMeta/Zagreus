import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class DiscoverHomeRoute extends StatefulWidget {
  const DiscoverHomeRoute({Key? key}) : super(key: key);

  @override
  State<DiscoverHomeRoute> createState() => _State();
}

class _State extends State<DiscoverHomeRoute> {
  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      appBar: ZagAppBar(
        title: 'Discover',
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_rounded,
              size: 100,
              color: const Color(0xFF6688FF),
            ),
            const SizedBox(height: 20),
            Text(
              'Discover',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6688FF),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Coming Soon',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}