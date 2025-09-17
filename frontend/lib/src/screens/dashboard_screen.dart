import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_state_notifier.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DriMain Dashboard'),
        actions: [
          Consumer<AuthStateNotifier>(
            builder: (context, authState, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    authState.logout();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person),
                        const SizedBox(width: 8),
                        Text(authState.currentUser ?? 'User'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(width: 4),
                      Text(authState.currentUser ?? 'User'),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthStateNotifier>(
        builder: (context, authState, child) {
          if (authState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCard(
                  context,
                  title: 'Zgłoszenia',
                  icon: Icons.report_problem,
                  color: Colors.orange,
                  onTap: () {
                    // TODO: Navigate to zgłoszenia screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Zgłoszenia - Coming Soon')),
                    );
                  },
                ),
                _buildDashboardCard(
                  context,
                  title: 'Harmonogramy',
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                  onTap: () {
                    // TODO: Navigate to harmonogramy screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Harmonogramy - Coming Soon')),
                    );
                  },
                ),
                _buildDashboardCard(
                  context,
                  title: 'Części',
                  icon: Icons.build,
                  color: Colors.green,
                  onTap: () {
                    // TODO: Navigate to części screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Części - Coming Soon')),
                    );
                  },
                ),
                _buildDashboardCard(
                  context,
                  title: 'Raporty',
                  icon: Icons.analytics,
                  color: Colors.purple,
                  onTap: () {
                    // TODO: Navigate to raporty screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Raporty - Coming Soon')),
                    );
                  },
                ),
                _buildDashboardCard(
                  context,
                  title: 'Admin Panel',
                  icon: Icons.admin_panel_settings,
                  color: Colors.red,
                  onTap: () {
                    // TODO: Navigate to admin screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Admin Panel - Coming Soon')),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}