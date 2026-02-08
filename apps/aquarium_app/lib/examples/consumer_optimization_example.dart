/// Consumer Optimization Example
/// 
/// This file demonstrates best practices for optimizing Riverpod rebuilds
/// using Consumer widgets to isolate rebuilds to only necessary subtrees.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Example providers (for demonstration)
final exampleTankProvider = StateProvider<String>((ref) => 'Tank 1');
final exampleLogsProvider = StateProvider<int>((ref) => 0);
final exampleTasksProvider = StateProvider<int>((ref) => 0);

// ❌ BAD: Entire widget rebuilds when ANY provider changes
class BadExample extends ConsumerWidget {
  const BadExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watching multiple providers at the top level
    final tank = ref.watch(exampleTankProvider);
    final logCount = ref.watch(exampleLogsProvider);
    final taskCount = ref.watch(exampleTasksProvider);

    print('🔴 BadExample: Entire widget rebuilt!');

    return Column(
      children: [
        Text('Tank: $tank'),
        Text('Logs: $logCount'),
        Text('Tasks: $taskCount'),
        
        // Even this static button rebuilds unnecessarily
        ElevatedButton(
          onPressed: () {},
          child: const Text('Static Button'),
        ),
      ],
    );
  }
}

// ✅ GOOD: Only specific sections rebuild when their data changes
class GoodExample extends StatelessWidget {
  const GoodExample({super.key});

  @override
  Widget build(BuildContext context) {
    print('✅ GoodExample: StatelessWidget built once');

    return Column(
      children: [
        // Only this section rebuilds when tank changes
        Consumer(
          builder: (context, ref, child) {
            final tank = ref.watch(exampleTankProvider);
            print('  🟢 Tank section rebuilt');
            return Text('Tank: $tank');
          },
        ),
        
        // Only this section rebuilds when logs change
        Consumer(
          builder: (context, ref, child) {
            final logCount = ref.watch(exampleLogsProvider);
            print('  🟢 Logs section rebuilt');
            return Text('Logs: $logCount');
          },
        ),
        
        // Only this section rebuilds when tasks change
        Consumer(
          builder: (context, ref, child) {
            final taskCount = ref.watch(exampleTasksProvider);
            print('  🟢 Tasks section rebuilt');
            return Text('Tasks: $taskCount');
          },
        ),
        
        // This static button NEVER rebuilds
        const ElevatedButton(
          onPressed: null,
          child: Text('Static Button'),
        ),
      ],
    );
  }
}

// ✅ EVEN BETTER: Use child parameter to avoid rebuilding static parts
class BestExample extends StatelessWidget {
  const BestExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer(
          // Static child passed through, not rebuilt
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.water_drop),
          ),
          builder: (context, ref, child) {
            final tank = ref.watch(exampleTankProvider);
            return Column(
              children: [
                child!, // Static icon
                Text('Tank: $tank'), // Dynamic text
              ],
            );
          },
        ),
      ],
    );
  }
}

// ✅ ADVANCED: Using select for granular subscriptions
final exampleUserProvider = StateProvider<User>((ref) => User('John', 25));

class User {
  final String name;
  final int age;
  User(this.name, this.age);
}

class SelectExample extends ConsumerWidget {
  const SelectExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuilds when name changes, not age
    final name = ref.watch(exampleUserProvider.select((user) => user.name));
    
    print('✅ SelectExample: Only rebuilds when name changes');

    return Column(
      children: [
        Text('Name: $name'),
        
        // Separate consumer for age
        Consumer(
          builder: (context, ref, child) {
            final age = ref.watch(exampleUserProvider.select((user) => user.age));
            print('  🟢 Age section rebuilt');
            return Text('Age: $age');
          },
        ),
      ],
    );
  }
}

// ✅ REAL-WORLD EXAMPLE: Tank Detail Screen optimization
class OptimizedTankDetailExample extends StatelessWidget {
  final String tankId;
  
  const OptimizedTankDetailExample({
    super.key,
    required this.tankId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tank Detail'),
      ),
      body: ListView(
        children: [
          // Tank header - only rebuilds when tank changes
          Consumer(
            builder: (context, ref, child) {
              // In real app: final tankAsync = ref.watch(tankProvider(tankId));
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Tank Header'),
                ),
              );
            },
          ),
          
          // Logs section - only rebuilds when logs change
          Consumer(
            builder: (context, ref, child) {
              // In real app: final logsAsync = ref.watch(logsProvider(tankId));
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Recent Logs'),
                ),
              );
            },
          ),
          
          // Tasks section - only rebuilds when tasks change
          Consumer(
            builder: (context, ref, child) {
              // In real app: final tasksAsync = ref.watch(tasksProvider(tankId));
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Tasks'),
                ),
              );
            },
          ),
          
          // Static section - never rebuilds
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Static Info'),
            ),
          ),
        ],
      ),
    );
  }
}

// 📊 Performance Impact:
//
// BAD: 
// - Tank changes → entire widget rebuilds (all 3 Text + Button)
// - Logs changes → entire widget rebuilds (all 3 Text + Button)
// - Tasks changes → entire widget rebuilds (all 3 Text + Button)
// Total: 12 widget rebuilds for 3 data changes
//
// GOOD:
// - Tank changes → only tank Text rebuilds
// - Logs changes → only logs Text rebuilds
// - Tasks changes → only tasks Text rebuilds
// Total: 3 widget rebuilds for 3 data changes
// 
// Result: 4x fewer rebuilds! 🚀

// 📝 When to use Consumer:
//
// ✅ Use Consumer when:
// - Multiple providers in one screen
// - Large widget trees
// - Independent sections that update separately
// - Screen has static content mixed with dynamic
//
// ❌ Don't use Consumer when:
// - Entire widget needs to rebuild anyway
// - Tiny widgets (overhead not worth it)
// - Simple screens with single provider

// 🎯 Quick Wins:
//
// 1. Identify screens that watch multiple providers at top level
// 2. Wrap each provider.watch in a Consumer
// 3. Move static widgets outside Consumer
// 4. Use select() for fine-grained subscriptions
// 5. Add RepaintBoundary on list items
// 6. Use const constructors everywhere possible
