import 'package:flutter/material.dart';
import '../widgets/fab_button.dart';
import '../widgets/auto_hide_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000817),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: AutoHideBottomNav.show,
        child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildMapPlaceholder(),
            const SizedBox(height: 12),
            _buildNearbyListTitle(),
            Expanded(child: _buildNearbyList()),
          ],
        ),
      ),),
      floatingActionButton: _buildFabs(),
      bottomNavigationBar: AutoHideBottomNav(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) {
            Navigator.pushReplacementNamed(context, '/rewards');
          } else if (i == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF001021),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF19C6FF),
            child: Text('AC', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rohit ',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white)),
              const Text('250 points',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white70),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white70),
            onPressed: () {},
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          hintText: 'Enter Bus ID or Route Number',
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF001021),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: const Color(0xFF19C6FF).withOpacity(0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF19C6FF)),
          ),
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          color: const Color(0xFF0A1224),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: const Text('Live Transit Map',
            style: TextStyle(color: Colors.white60)),
      ),
    );
  }

  Widget _buildNearbyListTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text('Nearby Buses',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildNearbyList() {
    final dummy = [
      {
        'route': 'Route 42',
        'status': 'Available',
        'eta': '3 min',
        'distance': '0.8 km',
        'busId': 'BUS-2834'
      },
      {
        'route': 'Route 15',
        'status': 'Full',
        'eta': '7 min',
        'distance': '1.2 km',
        'busId': 'BUS-1923'
      },
    ];
    return ListView.separated(
      itemCount: dummy.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, idx) {
        final item = dummy[idx];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF001021),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(item['route']!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 6),
                        _buildStatusChip(item['status']!),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Bus ID: ${item['busId']}',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(item['eta']!,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(item['distance']!,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    if (status == 'Available')
      bg = const Color(0xFF26C281);
    else if (status == 'Full')
      bg = const Color(0xFFFFB300);
    else
      bg = Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status,
          style: const TextStyle(color: Colors.white, fontSize: 10)),
    );
  }

  Widget _buildFabs() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FabButton(
          icon: Icons.search,
          colors: const [Color(0xFF19C6FF), Color(0xFF00B4FF)],
          onPressed: () {
            Navigator.pushNamed(context, '/track');
          },
        ),
        const SizedBox(height: 16),
        FabButton(
          icon: Icons.directions_bus,
          colors: const [Color(0xFF7A2CF0), Color(0xFF9B3BFF)],
          onPressed: () {
            Navigator.pushNamed(context, '/share');
          },
        ),
      ],
    );
  }
}
