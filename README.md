# HabitatOS
Habitat resource tracker for analog space missions
- Joseph Brian M. Azarraga - BSSE 2

## What it does

- Track consumables (food, water, anything else) with a starting quantity and
  a running stock history.
- Log a change at a specific date and time, with an optional note.
- See the current stock and a per-day usage average for every resource.
- Review, delete or clear the activity log.
- Data is stored on the device and survives a restart.

## Checks

```bash
flutter analyze
flutter test
```

## Project layout

```
lib/
  main.dart                 app entry point
  theme.dart                dark palette and Material theme
  gradient_border.dart      reusable card border
  models/                   Resource, StockEntry, StockPoint, LogEntry
  screens/                  dashboard shell, home, resources, logs, settings
  services/storage.dart     JSON persistence via shared_preferences
  utils/format.dart         shared date and number formatting
  widgets/stock_chart.dart  shared stock chart
assets/fonts/               bundled JetBrains Mono (OFL)
```
