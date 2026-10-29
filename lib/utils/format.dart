String two(int n) => n.toString().padLeft(2, '0');

String formatDate(DateTime t) => '${two(t.month)}-${two(t.day)}';

String formatTime(DateTime t) => '${two(t.hour)}:${two(t.minute)}';

String formatDateTime(DateTime t) => '${t.year}-${formatDate(t)} ${formatTime(t)}';

String signedDelta(int n) => n > 0 ? '+$n' : '$n';
