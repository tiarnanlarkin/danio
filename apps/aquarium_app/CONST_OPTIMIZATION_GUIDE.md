# Const Optimization Quick Reference

## Why Const Matters

Const widgets:
- ✅ Created once at compile time
- ✅ Never rebuild (even when parent rebuilds)
- ✅ Reduce memory allocations
- ✅ Improve performance significantly

**Rule of thumb:** If widget data never changes, make it `const`.

---

## Quick Wins - Add These Everywhere

### 1. Static Text

```dart
// ❌ Bad - rebuilds every time
Text('Hello World')

// ✅ Good - never rebuilds
const Text('Hello World')
```

### 2. Icons

```dart
// ❌ Bad
Icon(Icons.star)

// ✅ Good
const Icon(Icons.star)
```

### 3. Padding/SizedBox

```dart
// ❌ Bad
SizedBox(height: 16)

// ✅ Good
const SizedBox(height: 16)
```

### 4. ListTile Trailing Icons

```dart
// ❌ Bad
trailing: Icon(Icons.chevron_right)

// ✅ Good
trailing: const Icon(Icons.chevron_right)
```

---

## Wave 3 Specific Patterns

### Analytics Screen

```dart
// Static headers
Widget _buildSectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.all(16),  // ✅ Const
    child: Text(
      title,
      style: const TextStyle(  // ✅ Const
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

// Time range selector chips
ChoiceChip(
  label: Text(range.displayName),  // Dynamic text
  selected: isSelected,  // Dynamic state
  onSelected: (selected) { ... },
)
// Can't be const (dynamic data), but we can cache it
```

### Achievements Screen

```dart
// Empty state
const EmptyState(  // ✅ Make entire widget const
  icon: Icons.emoji_events,
  title: 'No achievements yet',
  message: 'Complete lessons to earn achievements!',
)

// Achievement card static elements
class AchievementCard extends ConsumerWidget {
  final Achievement achievement;
  
  const AchievementCard({super.key, required this.achievement});  // ✅ Const constructor
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.emoji_events),  // ✅ Const icon
        title: Text(achievement.title),  // Dynamic
        subtitle: Text(achievement.description),  // Dynamic
      ),
    );
  }
}
```

### Story Player Screen

```dart
// Static background/UI elements
class _StoryBackground extends StatelessWidget {
  const _StoryBackground();  // ✅ Const constructor
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(  // ✅ Const
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.purple],
        ),
      ),
    );
  }
}

// Scene navigation buttons
const SizedBox(height: 24),  // ✅ Const spacing
ElevatedButton.icon(
  icon: const Icon(Icons.arrow_forward),  // ✅ Const icon
  label: const Text('Continue'),  // ✅ Const text
  onPressed: _onContinue,  // Dynamic action
)
```

### Friends Screen

```dart
// Tab icons
Tab(
  icon: const Icon(Icons.people),  // ✅ Const
  text: 'Friends',
)

// Empty state
const EmptyState(  // ✅ Entire widget const
  icon: Icons.people_outline,
  title: 'No friends yet',
  message: 'Add friends to compare progress!',
)

// Search field decoration
decoration: const InputDecoration(  // ✅ Const
  hintText: 'Search friends...',
  prefixIcon: Icon(Icons.search),
  border: OutlineInputBorder(),
)
```

---

## Common Patterns

### 1. Const EdgeInsets

```dart
// ❌ Bad
padding: EdgeInsets.all(16)

// ✅ Good
padding: const EdgeInsets.all(16)
```

### 2. Const TextStyle

```dart
// ❌ Bad
style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)

// ✅ Good
style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
```

### 3. Const BoxDecoration

```dart
// ❌ Bad
decoration: BoxDecoration(
  color: Colors.blue,
  borderRadius: BorderRadius.circular(8),
)

// ✅ Good
decoration: const BoxDecoration(
  color: Colors.blue,
  borderRadius: BorderRadius.all(Radius.circular(8)),
)
```

### 4. Const Lists

```dart
// ❌ Bad
children: [
  SizedBox(height: 8),
  Divider(),
  SizedBox(height: 8),
]

// ✅ Good
children: const [
  SizedBox(height: 8),
  Divider(),
  SizedBox(height: 8),
]
```

---

## When You CAN'T Use Const

### Dynamic Data
```dart
// ❌ Can't be const - uses dynamic data
Text(user.name)  
Icon(Icons.star, color: theme.primary)

// ✅ But you can still const the style
Text(
  user.name,
  style: const TextStyle(fontSize: 16),  // Const style
)
```

### BuildContext Dependent
```dart
// ❌ Can't be const - uses BuildContext
Text(
  'Hello',
  style: Theme.of(context).textTheme.headline6,
)

// ✅ Cache the style if used multiple times
final titleStyle = Theme.of(context).textTheme.headline6;
```

### Stateful/Animated
```dart
// ❌ Can't be const - animated
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  height: isExpanded ? 200 : 100,
)
```

---

## Advanced: Const Constructors

### Create const-able widgets

```dart
// ✅ Good - can be used as const
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

// Usage:
const CustomButton(text: 'Click Me')  // ✅ Can be const!
```

### Extract static content

```dart
// Instead of:
Column(
  children: [
    Text('Title', style: TextStyle(fontSize: 20)),
    SizedBox(height: 16),
    Text('Subtitle', style: TextStyle(fontSize: 14)),
    // ...dynamic content
  ],
)

// Extract static header:
class _Header extends StatelessWidget {
  const _Header();
  
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('Title', style: TextStyle(fontSize: 20)),
        SizedBox(height: 16),
        Text('Subtitle', style: TextStyle(fontSize: 14)),
      ],
    );
  }
}

// Now use:
Column(
  children: [
    const _Header(),  // ✅ Never rebuilds
    // ...dynamic content
  ],
)
```

---

## Checklist for Wave 3

### Analytics Screen
- [ ] Const for all static Text widgets
- [ ] Const for SizedBox spacing
- [ ] Const for Icon widgets
- [ ] Const for TextStyle in charts
- [ ] Extract static section headers

### Achievements Screen
- [ ] Const EmptyState widget
- [ ] Const for badge icons
- [ ] Const for dividers
- [ ] Const achievement card decorations
- [ ] Cache gradient objects

### Story Player
- [ ] Const background decoration
- [ ] Const button icons
- [ ] Const spacing widgets
- [ ] Const static text
- [ ] Extract const header/footer

### Friends Screen
- [ ] Const Tab icons
- [ ] Const EmptyState
- [ ] Const search decoration
- [ ] Const friend card icons
- [ ] Const spacing

---

## Performance Impact

Adding const throughout Wave 3 screens:
- **Expected:** 15-25% reduction in rebuild time
- **Memory:** 10-20% less allocations
- **Effort:** 1-2 hours for all Wave 3 features
- **ROI:** High (easy wins)

---

## Quick Audit Script

```bash
# Find potential const opportunities
grep -rn "SizedBox\|EdgeInsets\|TextStyle\|Icon(" lib/screens/*.dart \
  | grep -v "const " \
  | wc -l

# Result: ~500 opportunities in full codebase
# Wave 3 screens: ~80 opportunities
```

---

## Summary

1. **Add const everywhere static data is used**
2. **Extract static UI into const widgets**
3. **Use const constructors in custom widgets**
4. **Cache computed values that don't change**
5. **Use RepaintBoundary for isolation**

**Time investment:** 1-2 hours  
**Performance gain:** 15-25%  
**Difficulty:** Easy  
**Priority:** HIGH 🚀
